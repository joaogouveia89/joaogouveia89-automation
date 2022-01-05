require "prawn"
require 'prawn/icon'
require "json"
require "date"

LINE_SPACING_HEADER = 5
LINE_SPACING = 2
LINE_SPACING_BIG = 8

datafile = "data-en.json"
if ARGV.size != 0
    if datafile = ARGV[0] == "pt"
        datafile = "data-pt.json"
    end
end

file = File.read(datafile)

json_file = JSON.parse(file)

birthdate = Date.parse json_file["header"]["birthdate"]

birthdate_str = datafile == "data-en.json" ?  birthdate.strftime('%F') : birthdate.strftime('%d/%m/%Y')

now = Time.now.utc.to_date
age =  now.year - birthdate.year - ((now.month > birthdate.month || (now.month == birthdate.month && now.day >= birthdate.day)) ? 0 : 1)

age_str = age.to_s + (datafile == "data-en.json" ? " years old" : " anos")

Prawn::Document.generate("resume.pdf") do
    text json_file["body"]["generated_on"] + now.year.to_s + "-" + ("%02d" % now.month).to_s + "-" + ("%02d" % now.day).to_s, align: :right, size: 8
    image "resources/joao.png", scale: 0.07
    text json_file["header"]["name"].upcase, align: :center, size: 20, style: :bold
    text "\n"
    icon '<icon size="11" color="000000">fas-birthday-cake</icon>' + "  " + birthdate_str + " (" + age_str + ")", size: 11, inline_format: true, leading: LINE_SPACING_HEADER
    icon '<icon size="11" color="000000">fas-ring</icon>' + "  " + json_file["header"]["marital_status"], size: 11, inline_format: true, leading: LINE_SPACING_HEADER
    icon '<icon size="11" color="000000">fas-home</icon>' + "  " + json_file["header"]["address"], size: 11, inline_format: true, leading: LINE_SPACING_HEADER
    icon '<icon size="11" color="000000">fas-phone</icon>' + "  " + json_file["header"]["phone"], size: 11, inline_format: true, leading: LINE_SPACING_HEADER
    icon '<icon size="11" color="000000">fas-envelope</icon>' + '  <link href="mailto:'+ json_file["header"]["email"] + '">' + json_file["header"]["email"]  + '</link>', size: 11, inline_format: true, leading: LINE_SPACING_HEADER
    icon '<icon size="11" color="000000">fab-github</icon>' + '  <link href="https://www.github.com/'+ json_file["header"]["github"] + '">' + json_file["header"]["github"]  + '</link>', size: 11, inline_format: true, leading: LINE_SPACING_HEADER
    icon '<icon size="11" color="000000">fab-skype</icon>' + "  " + json_file["header"]["skype"], size: 11, inline_format: true, leading: LINE_SPACING_HEADER
    text "\n\n"
    text json_file["body"]["position_name"], align: :center, size: 26, style: :bold, leading: LINE_SPACING_HEADER
    text "\n"
    text json_file["body"]["summary_description"], size: 14, leading: LINE_SPACING
    text "\n\n"
    text json_file["body"]["academic_formation"], align: :center, size: 20, style: :bold
    text "\n"
    json_file["academic_formation"].each do |af|
        text af["institution"], size: 14, style: :bold, leading: LINE_SPACING
        text af["title"], size: 14, leading: LINE_SPACING
        text af["start"] + " - " + af["end"], size: 14, leading: LINE_SPACING_BIG
        if af["comments"] != nil
            text af["comments"] , size: 14, style: :italic, leading: LINE_SPACING_BIG
        end
    end
    start_new_page
    json_file["speak_languages"].each do |sl|
        image sl["icon"], scale: 0.07
        text "\n"
        text sl["proeficience"], leading: LINE_SPACING_BIG, size: 14
    end
    text "\n"
    text json_file["body"]["professional_experience"], align: :center, size: 20, style: :bold
    text "\n"
    xp_summary_months = {}
    xp_summary_other = []
    json_file["relevant_xps"].each do |rxp|
        xp_summary_months[rxp] = 0
    end
    json_file["professional_experience"].reverse.each do |xp|
        text xp["role"] + " - " + xp["company"], size: 14, style: :bold, leading: LINE_SPACING
        text xp["start"].gsub("-", "/") + " - " + ((xp["end"] == nil) ? json_file["current"] : xp["end"].gsub("-", "/")), size: 14, leading: LINE_SPACING_BIG
        text xp["description"], size: 12, leading: LINE_SPACING
        end_xp_time = ((xp["end"] == nil) ? Time.now.utc.to_date : Date.parse("01-" + xp["end"]) )
        start_xp_time = Date.parse("01-" + xp["start"])
        xp_time =  (end_xp_time.year * 12 + end_xp_time.month) - (start_xp_time.year * 12 + start_xp_time.month)
        
        unless(xp["programming_languages"] == nil)
            xp["programming_languages"].each do |pl|
                if xp_summary_months.key? (pl)
                    xp_summary_months[pl] = xp_summary_months[pl] + xp_time
                end
            end
        end

        unless(xp["stack"] == nil)
            xp["stack"].each do |s|
                if xp_summary_months.key? (s)
                    xp_summary_months[s] = xp_summary_months[s] + xp_time
                else
                    xp_summary_other << s
                end
            end
        end
        
        text "\n"
    end
    xp_summary_other.uniq!
    text json_file["body"]["summary"], align: :center, size: 20, style: :bold
    text "\n"
    xp_summary_months.each {|xp, months|
        ys = months / 12
        ms = months % 12
        text xp + ": " + json_file["years_and_months"] % [ys, ms] , size: 14, leading: LINE_SPACING_BIG
    }
    text "\n"
    text json_file["body"]["summary_other"], size: 18, style: :bold
    text "\n"
    xp_summary_other.each {|xp|
        text xp, size: 14, leading: LINE_SPACING_BIG
    }
end