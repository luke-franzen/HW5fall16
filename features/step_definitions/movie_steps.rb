# Completed step definitions for basic features: AddMovie, ViewDetails, EditMovie 

Given /^I am on the RottenPotatoes home page$/ do
  visit movies_path
 end


 When /^I have added a movie with title "(.*?)" and rating "(.*?)"$/ do |title, rating|
  visit new_movie_path
  fill_in 'Title', :with => title
  select rating, :from => 'Rating'
  click_button 'Save Changes'
 end

 Then /^I should see a movie list entry with title "(.*?)" and rating "(.*?)"$/ do |title, rating| 
   result=false
   all("tr").each do |tr|
     if tr.has_content?(title) && tr.has_content?(rating)
       result = true
       break
     end
   end  
  expect(result).to be_truthy
 end

 When /^I have visited the Details about "(.*?)" page$/ do |title|
   visit movies_path
   click_on "More about #{title}"
 end

 Then /^(?:|I )should see "([^"]*)"$/ do |text|
    expect(page).to have_content(text)
 end

 When /^I have edited the movie "(.*?)" to change the rating to "(.*?)"$/ do |movie, rating|
  click_on "Edit"
  select rating, :from => 'Rating'
  click_button 'Update Movie Info'
 end


# New step definitions to be completed for HW5. 
# Note that you may need to add additional step definitions beyond these


# Add a declarative step here for populating the DB with movies.

Given /the following movies have been added to RottenPotatoes:/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create!(movie)
    # Each returned movie will be a hash representing one row of the movies_table
    # The keys will be the table headers and the values will be the row contents.
    # Entries can be directly to the database with ActiveRecord methods
    # Add the necessary Active Record call(s) to populate the database.
  end
end

When /^I have opted to see movies rated: "(.*?)"$/ do |arg1|
  # HINT: use String#split to split up the rating_list, then
  # iterate over the ratings and check/uncheck the ratings
  # using the appropriate Capybara command(s)
  visit movies_path
  
  uncheck('ratings_G')
  uncheck('ratings_PG')
  uncheck('ratings_PG-13')
  uncheck('ratings_NC-17')
  uncheck('ratings_R')
  
  ratings = arg1.split(',').each do |rating|
    check('ratings_'+rating.strip)
  end
  click_button('Refresh')
end

Then /^I should see only movies rated: "(.*?)"$/ do |arg1|
    result = true
    rh={}
    
    arg1.split(',').each do |rating|
        rating2 = rating.strip
        rh[rating2]=1
        if rating2 == 'NC-17'
            next
        elsif page.has_no_css?('td', :text => /\A#{rating2}\z/)
            result = false
        end
    end
    
    x = ['G','PG','PG-13','R','NC-17']
    
    x.each do |rating3|
        if !rh.has_key?(rating3)
            if page.has_css?('td', :text => /\A#{rating3}\z/)
                result = false
            end
        end
    end
    
    expect(result).to be_truthy
end


Then /^I should see all of the movies$/ do
  rows=0
  find('tbody').all('tr').each do |tr|
   rows+=1
  end
  
  rows.should == Movie.all.count 
end

When /^I have sorted movies alphabetically$/ do
    click_on "title_header"
end

Then /^I should see "(.*?)" before "(.*?)"$/ do |title1, title2|
    regex = /#{title1}{1}.*#{title2}{1}/m
    page.body =~ regex
end

When /^I have sorted movies by ascending release date$/ do
    click_on "release_date_header"
end

Then /^I will see "(.*?)" before "(.*?)"$/ do |title1, title2|
    regex = /#{title1}{1}.*#{title2}{1}/m
    page.body =~ regex
end