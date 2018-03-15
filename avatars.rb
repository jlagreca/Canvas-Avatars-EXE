
require 'unirest'
require 'csv'
require 'json'
require 'highline/import'

domain = ask("What is your Canvas subdomain? (the bit that goes before .instructure.com)  ")
env = ask("Which environment do you want to use? (beta, test) just leave BLANK and press enter for production  ")
course_id = ask("What is the SIS_COURSE_ID where your images are located?  ")
csv_file = ask("What is the name of your CSV file, including the .csv. This file should be in the same location as your .exe file   ")
access_token = ask("Please input your admin token  ")
report_file = 'error_report.csv'

fileheaders = ["user_sis_id", "image_used", "image_url", "latest_update","error"]
   CSV.open("#{report_file}", "w") do |csv| #open new file for write
      csv << fileheaders
   end


env != '' ? env << '.' : env
base_url = "https://#{domain}.#{env}instructure.com/api/v1"


Unirest.default_header("Authorization", "Bearer #{access_token}")


CSV.foreach(csv_file, {:headers => true}) do |row|

  image_get = "https://#{domain}.#{env}instructure.com/api/v1/courses/sis_course_id:#{course_id}/files"

  image_data = Unirest.get(image_get, parameters: { "search_term" => row['user_id'], "sort" => "updated_at" })

  image_array = image_data.body

  if image_array.empty?  
    puts "sorry user with sis_id #{row['user_id']} doesnt have a image in the course."
    puts "Skipping"
    data = [ row['user_id'], "No Image Found", "Not Available", "latest_update","There was no image called #{row['user_id']}.jpg in course #{course_id}"]
    CSV.open("#{report_file}", "a") do |csv| #open same file for write
      csv << data #write value to file
    end
  else

  image_array.each do |image|
    image_name = image['display_name']
    avatar_url = image['url']
    image_update = image['updated_at']
    url = "#{base_url}/users/sis_user_id:#{row['user_id']}.json"

    update = Unirest.put(url, parameters: { "user[avatar][url]" => avatar_url })
    
      if update.code == 200
        puts "User with SIS ID #{row['user_id']} has had their avatar updated."
        data = [ row['user_id'], image_name, avatar_url, image_update ,"Updated Successfully"]
          CSV.open("#{report_file}", "a") do |csv| #open same file for write
          csv << data #write value to file
          end
      else
        puts "User with SIS ID #{row['user_id']} failed to update."
        puts "Moving right along."
        data = [ row['user_id'], image_name, avatar_url, image_update, update.code]
          CSV.open("#{report_file}", "a") do |csv| #open same file for write
          csv << data #write value to file
        end
      end

  end

end
end
puts "Finished updating avatars. Have yourself and awesome day!"

