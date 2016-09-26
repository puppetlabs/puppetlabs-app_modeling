require_relative '../app_modeling_monitor'
require 'net/http'
require 'uri'

Puppet::Type.type(:http).provide(:http,
                                 :parent => Puppet::Provider::AppModelingMonitor) do

  def notice_for_failure(msg)
    Puppet.notice "Unable to connect to service (#{generate_uri}). #{msg}"
    false
  end

  def validate
    response = Net::HTTP.start(resource[:ip], resource[:port],
                               :use_ssl => resource[:ssl]) do |http|

      request = Net::HTTP::Get.new(generate_uri)
      http.request(request)
    end

    unless resource[:status_codes].include?(Integer(response.code))
      return notice_for_failure("Response code #{response.code} did not match status_codes #{resource[:status_codes].join(",")}.")
    end
    true
  rescue Exception => e
    notice_for_failure(e.message)
  end

  def generate_uri
    uri_part = (resource[:ssl] ? 'https' : 'http') + "://" + resource[:host] + ":" + resource[:port].to_s
    URI.join(uri_part, resource[:base_path])
  end
end
