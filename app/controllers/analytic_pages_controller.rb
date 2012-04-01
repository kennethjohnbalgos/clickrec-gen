class AnalyticPagesController < ApplicationController
  require 'open-uri'
  def test
    render :text => params[:url]
  end
  def recordClick
    logger.info ">>>>> Recording Click"
    
    # Initialize
    val = request.query_parameters
    val_url = AnalyticPage.completeURL(val['url'])
    val_domain = AnalyticPage.getDomain(val_url)
    val_title = AnalyticPage.getTitle(val_url)
    
    if AnalyticPage.isExisting(val_url, val_domain)
      page_record = AnalyticPage.getRecord(val_url, val_domain)
    else  
      page_record = AnalyticPage.addRecord(val_title, val_url, val_domain, request.url)
    end
    
    browserInfo = request.env['HTTP_USER_AGENT']
    ipaddress = request.remote_ip
    
    click_record = AnalyticClick.addRecord(page_record, val['userid'], browserInfo, ipaddress, val['source'])
    logger.info ">>>>> Page Record: #{page_record.to_json}"
    logger.info ">>>>> Click Record: #{click_record.to_json}"
    redirect_to "#{val_url}"
  end
  
  
end
