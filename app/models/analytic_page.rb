class AnalyticPage < ActiveRecord::Base
  has_many :analytic_clicks
  has_many :analytic_visits
  has_many :analytic_day_logs
  
  DOMAIN_LIVE = "trainingmagnetwork.com"
  DOMAIN_TEST = "flashsimplified.com"
  
  def self.completeURL(url)
    url[0..3].downcase == "http" ? "#{url}" : "http://#{url}"
  end
  
  def self.getDomain(url)
    domain = URI.parse(URI.encode(url)).host
    domain.split('.').size == 2 ? "www.#{domain}" : "#{domain}"
  end
  
  def self.isInternal(current, url)
    dom_live = DOMAIN_LIVE
    dom_test = DOMAIN_TEST
    dom_current = getDomain(current).gsub("www.","")
    dom_url = url
    if dom_url.index(dom_live) != nil || dom_url.index(dom_current) != nil # dom_url.index(dom_test) != nil || 
      true
    else
      false
    end
  end
  
  def self.getTitle(url)
    begin
      page = Pismo::Document.new(url)
      page.title
      # agent = Mechanize.new
      # agent.get(url)
      # agent.page.title
    rescue
      nil
    end
  end
  
  def self.isActive(title)
    title != nil ? true : false
  end
  
  def self.isExisting(url, domain)
    record = AnalyticPage.exists?(
      :url => url,
      :domain => domain
    )
  end
  
  def self.getRecord(url, domain)
    AnalyticPage.find_by_url_and_domain(url, domain)
  end
  
  def self.addRecord(title, url, domain, current_url)
    internal = isInternal(current_url,url)
    active = isActive(title)
    AnalyticPage.create(
      :title => title, 
      :url => url, 
      :domain => domain,
      :internal => internal,
      :active => active
    )
  end
  
  def self.updateTitle(page, title)
    if page.title != title
      page.title = title
      page.save
    end
  end
  
  def self.makeActive(page)
    page.active = true
    page.save
  end
  
  def self.getBrowserName(env)
    details = env
    if details =~ /Safari/
      unless details =~ /Chrome/
        browser = "Safari"
        version = details.split('Version/')[1].split(' ').first.split('.').first
      else
        browser = "Chrome"
        version = details.split('Chrome/')[1].split(' ').first.split('.').first
      end
    elsif details =~ /Firefox/
      browser = "Firefox"
      version = details.split('Firefox/')[1].split('.').first
    elsif details =~ /Opera/
      browser = "Opera"
      version = details.split('Version/')[1].split('.').first
    elsif details =~ /MSIE/
      browser = "Internet Explorer"
      version = details.split('MSIE')[1].split(' ').first
    end
    return "#{browser}-#{version}"
  end
  
  def self.domain_visible_clicks(domain)
    pages = AnalyticPage.find(:all,:conditions=>{:domain=>domain,:hidden=>false})
    total = 0
    pages.each do |x|
      total += AnalyticClick.count(:id,:conditions=>{:analytic_page_id=>x.id})
    end
    total
  end
  
  def self.domain_visible_visits(domain)
    pages = AnalyticPage.find(:all,:conditions=>{:domain=>domain,:hidden=>false})
    total = 0
    pages.each do |x|
      total += AnalyticVisit.count(:id,:conditions=>{:analytic_page_id=>x.id})
    end
    total
  end
  
  def self.domain_all_clicks(domain)
    pages = AnalyticPage.find(:all,:conditions=>{:domain=>domain})
    total = 0
    pages.each do |x|
      total += AnalyticClick.count(:id,:conditions=>{:analytic_page_id=>x.id})
    end
    total
  end
  
  def self.domain_all_visits(domain)
    pages = AnalyticPage.find(:all,:conditions=>{:domain=>domain})
    total = 0
    pages.each do |x|
      total += AnalyticVisit.count(:id,:conditions=>{:analytic_page_id=>x.id})
    end
    total
  end
  
  def self.domain_visible_pages(domain)
    AnalyticPage.count(:id,:conditions=>{:domain=>domain,:hidden=>false})
  end
  
  def self.domain_hidden_pages(domain)
    AnalyticPage.count(:id,:conditions=>{:domain=>domain,:hidden=>true})
  end
  
  def display_title
    if self.title != nil
      if self.title.last(5) == "Login" && self.url.last(5) != "login"
        "-- Could not fetch title of secured page, title will be saved upon visiting the page."
      else
        self.title.gsub("&raquo;","»").gsub("&reg;","®")
      end
    else
      "Unknown Title"
    end
  end
end
