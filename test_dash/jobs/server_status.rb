#!/usr/bin/env ruby
require 'net/http'
require 'uri'

# Check whether a server is responding
# you can set a server to check via http request or ping
#
# server options:
# name: how it will show up on the dashboard
# url: either a website url or an IP address (do not include https:// when usnig ping method)
# method: either 'http' or 'ping'
# if the server you're checking redirects (from http to https for example) the check will
# return false

servers = [{:name=> 'randstad', :url=> 'https://randstad.crunchrapps.com', :method=> 'http'},
           {:name=> 'naspers', :url=> 'https://naspers.crunchrapps.com', :method=> 'http'},
           {:name=> 'demo', :url=> 'https://demo.crunchrapps.com', :method=> 'http'},
           {:name=> 'tudelft', :url=> 'https://tudelft.crunchrapps.com', :method=> 'http'},
           {:name=> 'crystal', :url=> 'https://crystal.crunchrapps.com', :method=> 'http'},
           {:name=> 'chicago', :url=> 'https://chicago.crunchrapps.com', :method=> 'http'},
           {:name=> 'randstad', :url=> 'randstad.crunchrapps.com', :method=> 'ping'},
           {:name=> 'randstad', :url=> 'https://randstad.crunchrapps.com', :method=> 'http'},
           {:name=> 'randstad', :url=> 'https://randstad.crunchrapps.com', :method=> 'http'},]

SCHEDULER.every '1m', :first_in => 0 do |job|

	statuses = Array.new

	# check status for each server
	servers.each do |server|
		if server[:method] == 'http'
			uri = URI.parse(server[:url])
			http = Net::HTTP.new(uri.host, uri.port)
			if uri.scheme == "https"
				http.use_ssl=true
				http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			end
			request = Net::HTTP::Get.new(uri.request_uri)
			response = http.request(request)
			if response.code == "200"
			 	result = 1
			 else
			 	result = 0
			 end
		elsif server[:method] == 'ping'
			ping_count = 10
			result = `ping -q -c #{ping_count} #{server[:url]}`
			if ($?.exitstatus == 0)
				result = 1
			else
				result = 0
			end
		end

		if result == 1
			arrow = "fa fa-check"
			color = "green"
		else
			arrow = "fa fa-times"
			color = "red"
		end

		statuses.push({label: server[:name], value: result, arrow: arrow, color: color})
	end

	# print statuses to dashboard
	send_event('server_status', {items: statuses})
end
