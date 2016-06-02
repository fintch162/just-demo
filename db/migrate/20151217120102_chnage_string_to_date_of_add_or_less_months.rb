class ChnageStringToDateOfAddOrLessMonths < ActiveRecord::Migration
	def up
		a = MoreOrLessMonth.pluck(:id, :start_month, :end_month, :start_month_atte, :end_month_atte)
		MoreOrLessMonth.update_all(start_month: nil, end_month: nil, start_month_atte: nil, end_month_atte: nil)
		change_column :more_or_less_months, :start_month, 'Date USING CAST(start_month AS Date)'
		change_column :more_or_less_months, :end_month, 'Date USING CAST(end_month AS Date)'
		change_column :more_or_less_months, :start_month_atte, 'Date USING CAST(start_month_atte AS Date)'
		change_column :more_or_less_months, :end_month_atte, 'Date USING CAST(end_month_atte AS Date)'
		a.each do |a|
			if a[1].present? && a[2].present?
		    a[1] = Date.parse "1 #{a[1].gsub("-", " ")}"
				month = a[2].to_date.strftime("%m").to_i
		    year = ('1-'+a[2]).to_date.strftime("%Y").to_i
		    endDateCnt = Time.days_in_month(month, year)
		    a[2] = Date.parse "#{endDateCnt} #{a[2].gsub("-", " ")}"
			end
			if a[3].present? && a[4].present?
		    month = a[4].to_date.strftime("%m").to_i
		    year = ('1-'+a[4]).to_date.strftime("%Y").to_i
		    endDateCnt = Time.days_in_month(month, year)
		    a[3] = Date.parse "1 #{a[3].gsub("-", " ")}"
		    a[4] = Date.parse "#{endDateCnt} #{a[4].gsub("-", " ")}" 
		    
				MoreOrLessMonth.find(a[0]).update_attributes(start_month: a[1].to_date.beginning_of_month, end_month: a[2].to_date.end_of_month, start_month_atte: a[3].to_date.beginning_of_month, end_month_atte: a[4].to_date.end_of_month)
			end
		end
	end
	def down  
		a = MoreOrLessMonth.pluck(:id, :start_month, :end_month, :start_month_atte, :end_month_atte)
		MoreOrLessMonth.update_all(start_month: nil, end_month: nil, start_month_atte: nil, end_month_atte: nil)
		change_column :more_or_less_months, :start_month, :string
		change_column :more_or_less_months, :end_month, :string
		change_column :more_or_less_months, :start_month_atte, :string
		change_column :more_or_less_months, :end_month_atte, :string
		a.each do |a|
			if !a[1].nil? 
				MoreOrLessMonth.find(a[0]).update_attributes(start_month: a[1].strftime("%b-%y"), end_month: a[2].strftime("%b-%y"), start_month_atte: a[3].strftime("%b-%y"), end_month_atte: a[4].strftime("%b-%y"))
			else
				MoreOrLessMonth.find(a[0]).update_attributes(start_month: nil, end_month: nil, start_month_atte: nil, end_month_atte: nil)
			end
		end
	end
end