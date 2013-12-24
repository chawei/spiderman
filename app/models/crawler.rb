require 'open-uri'

class Crawler
  SEARCH_URI = "http://www.amazon.com/s/ref=nb_sb_noss_1?url=search-alias%3Daps&field-keywords="
  
  TITLE_PATTERN = '.newaps'
  LINK_PATTERN  = '.newaps a'
  PRICE_PATTERN = '.newp .red'
  PRIME_PATTERN = '.newp .sprPrime'
  STOCK_PATTERN = '.rsltL .sml'
  
  attr_accessor :browser
  attr_accessor :results
  
  def browser
    if @browser.nil?
      @browser = Watir::Browser.new :safari
    end
    @browser
  end
  
  def search(query)
    @results     = []
    
    browser.goto SEARCH_URI+query
    parse_html browser.html
  end
  
  def next_page
    #browser.link(:text => "Next Page").when_present.click
    browser.link(:text => "Next Page").click
  end
  
  def parse_product_url(url)
    browser.goto url
    parse_product_html browser.html
  end
  
  def parse_product_html(html)
    doc = Nokogiri::HTML.parse(html)
    title         = get_parsed_text doc.search('#title')
    description   = doc.search('#productDescription .content')
    price         = get_parsed_text doc.search('#priceblock_ourprice')
    availability  = get_parsed_text doc.search('#availability')
    merchant_info = get_parsed_text doc.search('#merchant-info')
    images        = doc.search('#altImages img')
    
    return {
      :title          => title,
      :description    => description,
      :price          => price,
      :availability   => availability,
      :is_in_stock    => in_stock?(availability),
      :merchant_info  => merchant_info,
      :is_from_amazon => from_amazon?(merchant_info),
      :images         => images
    }
  end
  
  def in_stock?(availability)
    if availability == "In Stock." || availability.include?('left in stock')
      true
    else
      false
    end
  end
  
  def from_amazon?(merchant_info)
    if merchant_info.include?('Ships from and sold by Amazon.com')
      true
    else
      false
    end
  end
  
  def image_nodes_to_srcs(image_nodes)
    srcs = []
    image_nodes.each do |image_node|
      srcs << to_src(image_node)
    end
    return srcs
  end
  
  def to_src(image_node)
    if image_node
      image_node.attributes['src'].value
    end
  end
  
  def get_parsed_text(node)
    if node
      cleanup node.text
    end
  end
  
  def cleanup(str)
    if str
      str.gsub(/\n/, "").strip
    end
  end
  
  def parse_html(html)
    doc         = Nokogiri::HTML.parse(html)
    raw_results = doc.search('.prod')
    raw_results.each do |raw_result|
      result = {
        :title      => get_title(raw_result),
        :link       => get_link(raw_result),
        :price      => get_price(raw_result),
        :stock_info => get_stock_info(raw_result),
        :is_prime   => is_prime?(raw_result)
      }
      @results << result
    end
    
    @results
  end
  
  def get_title(result)
    raw_title = result.search(TITLE_PATTERN)
    if raw_title.length > 0
      raw_title.text.strip
    else
      'not found'
    end
  end
  
  def get_link(result)
    raw_link = result.search(LINK_PATTERN)
    if raw_link.length > 0
      raw_link[0].attributes['href'].value
    else
      nil
    end
  end
  
  def get_price(result)
    raw_price = result.search(PRICE_PATTERN)
    if raw_price.length > 0
      raw_price.text.strip
    else
      'not found'
    end
  end
  
  def get_stock_info(result)
    raw_price = result.search(STOCK_PATTERN)
    if raw_price.length > 0
      raw_price.text.strip
    else
      'not found'
    end
  end
  
  def is_prime?(result)
    raw_prime = result.search(PRIME_PATTERN)
    if raw_prime.length > 0
      true
    else
      false
    end
  end
  
end