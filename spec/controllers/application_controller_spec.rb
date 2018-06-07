require 'spec_helper'

describe ApplicationController do

  describe "Homepage" do
    it 'loads the homepage' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to Fwitter")
    end
  end

  describe "Signup Page" do

    it 'loads the signup page' do
      get '/signup'
      expect(last_response.status).to eq(200)
    end

    it 'signup directs user to twitter index' do
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include("/hacks")
    end

    it 'does not let a user sign up without a username' do
      params = {
        :username => "",
        :email => "skittles@aol.com",
        :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without an email' do
      params = {
        :username => "skittles123",
        :email => "",
        :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without a password' do
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => ""
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a logged in user view the signup page' do
      user = User.create(:username => "skittles123", :email => "skittles@aol.com", :password => "rainbows")
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => "rainbows"
      }
      post '/signup', params
      session = {}
      session[:user_id] = user.id
      get '/signup'
      expect(last_response.location).to include('/hacks')
    end
  end

  describe "login" do
    it 'loads the login page' do
      get '/login'
      expect(last_response.status).to eq(200)
    end

    it 'loads the hacks index after login' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome,")
    end

    it 'does not let user view login page if already logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      session = {}
      session[:user_id] = user.id
      get '/login'
      expect(last_response.location).to include("/hacks")
    end
  end

  describe "logout" do
    it "lets a user logout if they are already logged in" do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      get '/logout'
      expect(last_response.location).to include("/login")
    end

    it 'does not let a user logout if not logged in' do
      get '/logout'
      expect(last_response.location).to include("/")
    end

    it 'does not load /hacks if user not logged in' do
      get '/hacks'
      expect(last_response.location).to include("/login")
    end

    it 'does load /hacks if user is logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")


      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      expect(page.current_path).to eq('/hacks')
    end
  end

  describe 'user show page' do
    it 'shows all a single users hacks' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      hack1 = Hack.create(:description => "hacking!", :user_id => user.id)
      hack2 = Hack.create(:description => "hack hack hack", :user_id => user.id)
      get "/users/#{user.slug}"

      expect(last_response.body).to include("hacking!")
      expect(last_response.body).to include("hack hack hack")

    end
  end

  describe 'index action' do
    context 'logged in' do
      it 'lets a user view the hacks index if logged in' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        hack1 = Hack.create(:description => "hacking!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        hack2 = Hack.create(:description => "look at this hack", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/hacks"
        expect(page.body).to include(hack1.description)
        expect(page.body).to include(hack2.description)
      end
    end

    context 'logged out' do
      it 'does not let a user view the hacks index if not logged in' do
        get '/hacks'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'new action' do
    context 'logged in' do
      it 'lets user view new hack form if logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/hacks/new'
        expect(page.status_code).to eq(200)
      end

      it 'lets user create a hack if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/hacks/new'
        fill_in(:description, :with => "hack!!!")
        click_button 'submit'

        user = User.find_by(:username => "becky567")
        hack = Hack.find_by(:description => "hack!!!")
        expect(hack).to be_instance_of(Hack)
        expect(hack.user_id).to eq(user.id)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user hack from another user' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/hacks/new'

        fill_in(:description, :with => "hack!!!")
        click_button 'submit'

        user = User.find_by(:id=> user.id)
        user2 = User.find_by(:id => user2.id)
        hack = Hack.find_by(:description => "hack!!!")
        expect(hack).to be_instance_of(Hack)
        expect(hack.user_id).to eq(user.id)
        expect(hack.user_id).not_to eq(user2.id)
      end

      it 'does not let a user create a blank hack' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/hacks/new'

        fill_in(:description, :with => "")
        click_button 'submit'

        expect(Hack.find_by(:description => "")).to eq(nil)
        expect(page.current_path).to eq("/hacks/new")
      end
    end

    context 'logged out' do
      it 'does not let user view new hack form if not logged in' do
        get '/hacks/new'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'show action' do
    context 'logged in' do
      it 'displays a single hack' do

        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        hack = Hack.create(:description => "i am a boss at hacking", :user_id => user.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit "/hacks/#{hack.id}"
        expect(page.status_code).to eq(200)
        expect(page.body).to include("Delete Hack")
        expect(page.body).to include(hack.description)
        expect(page.body).to include("Edit Hack")
      end
    end

    context 'logged out' do
      it 'does not let a user view a hack' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        hack = Hack.create(:description => "i am a boss at hacking", :user_id => user.id)
        get "/hacks/#{hack.id}"
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'edit action' do
    context "logged in" do
      it 'lets a user view hack edit form if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        hack = Hack.create(:description => "hacking!", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/hacks/1/edit'
        expect(page.status_code).to eq(200)
        expect(page.body).to include(hack.description)
      end

      it 'does not let a user edit a hack they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        hack1 = Hack.create(:description => "hacking!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        hack2 = Hack.create(:description => "look at this hack", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        session = {}
        session[:user_id] = user1.id
        visit "/hacks/#{hack2.id}/edit"
        expect(page.current_path).to include('/hacks')
      end

      it 'lets a user edit their own hack if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        hack = Hack.create(:description => "hacking!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/hacks/1/edit'

        fill_in(:description, :with => "i love hacking")

        click_button 'submit'
        expect(Hack.find_by(:description => "i love hacking")).to be_instance_of(Hack)
        expect(Hack.find_by(:description => "hacking!")).to eq(nil)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user edit a text with blank description' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        hack = Hack.create(:description => "hacking!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/hacks/1/edit'

        fill_in(:description, :with => "")

        click_button 'submit'
        expect(Hack.find_by(:description => "i love hacking")).to be(nil)
        expect(page.current_path).to eq("/hacks/1/edit")
      end
    end

    context "logged out" do
      it 'does not load -- instead redirects to login' do
        get '/hacks/1/edit'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'delete action' do
    context "logged in" do
      it 'lets a user delete their own hack if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        hack = Hack.create(:description => "hacking!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit 'hacks/1'
        click_button "Delete Hack"
        expect(page.status_code).to eq(200)
        expect(Hack.find_by(:description => "hacking!")).to eq(nil)
      end

      it 'does not let a user delete a hack they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        hack1 = Hack.create(:description => "hacking!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        hack2 = Hack.create(:description => "look at this hack", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "hacks/#{hack2.id}"
        click_button "Delete Hack"
        expect(page.status_code).to eq(200)
        expect(Hack.find_by(:description => "look at this hack")).to be_instance_of(Hack)
        expect(page.current_path).to include('/hacks')
      end
    end

    context "logged out" do
      it 'does not load let user delete a hack if not logged in' do
        hack = Hack.create(:description => "hacking!", :user_id => 1)
        visit '/hacks/1'
        expect(page.current_path).to eq("/login")
      end
    end
  end
end
