class AnalyticVisit < ActiveRecord::Base
  belongs_to :analytic_page
  belongs_to :analytic_click
  belongs_to :user
  
  def self.recordVisit(val_title,val_url,ipaddress,browserInfo,current_user)
    logger.info ">>>>> Recording Visit"
    begin
      val_domain = AnalyticPage.getDomain(val_url)
      if AnalyticPage.isExisting(val_url, val_domain)
        page_record = AnalyticPage.getRecord(val_url, val_domain)
        AnalyticPage.updateTitle(page_record, val_title)
      else  
        page_record = AnalyticPage.addRecord(val_title, val_url, val_domain, val_url)
      end
      visit_record = AnalyticVisit.addRecord(page_record, current_user, browserInfo, ipaddress)
      logger.info ">>>>> Page Record: #{page_record.to_json}"
      logger.info ">>>>> Visit Record: #{visit_record.to_json}"
      AnalyticPage.makeActive(page_record)
      tagClick(page_record,visit_record) if hasClick(page_record,visit_record)
    rescue
      logger.info ">>>>> An error occured!"
    end
  end
  
  def self.addRecord(page, c_user, browser, ip)
    if browser
      user = c_user ? c_user.id : 0
      click_id = 0
      clicked = false
      geo = Geocoder.search(ip.to_s)
      if ip == "127.0.0.1"
        location = "Local Computer"
      else
        location = "#{geo[0].data['city']}, #{geo[0].data['country_name']}"
      end
      record = AnalyticVisit.new(
        :analytic_page_id => page.id, 
        :analytic_click_id => click_id,
        :user_id => user, 
        :browser => AnalyticPage.getBrowserName(browser),
        :browser_details => browser,
        :ip_address => ip,
        :location => location,
        :clicked => clicked
      )
      AnalyticDayLog.addVisit(page) if record.save!
      return record
    end
  end
  
  def self.hasClick(page, visit)
    AnalyticClick.exists?(
      :analytic_page_id => page.id,
      # :browser => visit.browser,
      # :browser_details => visit.browser_details,
      :ip_address => visit.ip_address,
      :loaded => false
    )
  end
  
  def self.tagClick(page, visit)
    click = AnalyticClick.find(
      :last,
      :conditions => {
        :analytic_page_id => page.id,
        # :browser => visit.browser,
        # :browser_details => visit.browser_details,
        :ip_address => visit.ip_address,
        :loaded => false
      }
    )
    click.loaded = true
    click.user_id = visit.user_id
    visit.analytic_click_id = click.id
    visit.clicked = true
    AnalyticDayLog.addClickVisit(page) if click.save! && visit.save!
  end
  
  
  def display_browser
    browser = self.browser
    if browser == "-"
      "Unknown"
    else
      browser = browser.gsub("Chrome","Google Chrome")
      browser = browser.gsub("Safari","Apple Safari")
      browser = browser.gsub("Firefox","Mozilla Firefox")
      browser = browser.gsub("-"," ver ")
      browser = browser += ".0"
      browser
    end
  end
  
  def display_location
    if self.location[0..0] == ","
      self.location.gsub(", ","")
    else
      self.location
    end
  end
  
end
