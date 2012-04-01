class AnalyticClick < ActiveRecord::Base
  belongs_to :analytic_page
  has_one :analytic_visit
  belongs_to :user
  
                          
  
  def self.addRecord(page, c_user, browser, ip, source)
    user = c_user ? c_user : 0
    record = AnalyticClick.new(
      :analytic_page_id => page.id, 
      :user_id => user, 
      :browser => AnalyticPage.getBrowserName(browser),
      :browser_details => browser,
      :ip_address => ip,
      :source => source,
      :loaded => false
    )
    AnalyticDayLog.addClick(page) if record.save!
    return record
  end
  
  
  def display_browser
    browser = self.browser
    browser = browser.gsub("Chrome","Google Chrome")
    browser = browser.gsub("Safari","Apple Safari")
    browser = browser.gsub("Firefox","Mozilla Firefox")
    browser = browser.gsub("-"," ver ")
    browser = browser += ".0"
  end
  
end
