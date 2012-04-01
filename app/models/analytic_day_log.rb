class AnalyticDayLog < ActiveRecord::Base
  belongs_to :analytic_page
  
  def self.getLog(page,date)
    if AnalyticDayLog.find_by_sql("SELECT id FROM analytic_day_logs WHERE analytic_page_id = #{page.id.to_i} AND date('#{date.to_date.strftime("%Y-%m-%d")}') = date(created_at)") == []
      AnalyticDayLog.create(
        :analytic_page_id => page.id,
        :click_count => 0,
        :visit_count => 0,
        :click_visit => 0
      )
    else
      AnalyticDayLog.find_by_sql("SELECT * FROM analytic_day_logs WHERE analytic_page_id = #{page.id.to_i} AND date('#{date.to_date.strftime("%Y-%m-%d")}') = date(created_at)")[0]
    end
  end
  
  def self.addClick(page)
    c_record = AnalyticDayLog.getLog(page,Time.now)
    c_record.click_count += 1
    c_record.save
  end
  
  def self.addVisit(page)
    v_record = AnalyticDayLog.getLog(page,Time.now)
    v_record.visit_count += 1
    v_record.save
  end

  def self.addClickVisit(page)
    cv_record = AnalyticDayLog.getLog(page,Time.now)
    cv_record.click_visit += 1
    cv_record.save
  end
  
end
