require 'open-uri'

class Crawler
  SEARCH_URI = "http://www.amazon.com/s/ref=nb_sb_noss_1?url=search-alias%3Daps&field-keywords="
  
  TITLE_PATTERN = '.newaps'
  PRICE_PATTERN = '.newp .red'
  STOCK_PATTERN = '.rsltL .sml'
  
  attr_accessor :browser
  attr_accessor :results
  
  def search(query)
    @results     = []
    
    @browser = Watir::Browser.new :safari
    @browser.goto SEARCH_URI+query
    parse_html @browser.html
  end
  
  def parse_html(html)
    doc          = Nokogiri::HTML.parse(html)
    raw_results = doc.search('.rslt')
    raw_results.each do |raw_result|
      result = {
        :title      => get_title(raw_result),
        :price      => get_price(raw_result),
        :stock_info => get_stock_info(raw_result)
      }
      @results << result
    end
    
    @results
  end
  
  def next_page
    @browser.link(:text => "Next Page").when_present.click
  end
  
  def get_title(result)
    if raw_title = result.search(TITLE_PATTERN)
      raw_title.text.strip
    else
      'not found'
    end
  end
  
  def get_price(result)
    if raw_price = result.search(PRICE_PATTERN)
      raw_price.text.strip
    else
      'not found'
    end
  end
  
  def get_stock_info(result)
    if raw_price = result.search(STOCK_PATTERN)
      raw_price.text.strip
    else
      'not found'
    end
  end
  
end