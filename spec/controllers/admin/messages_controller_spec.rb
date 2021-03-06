require 'spec_helper'

describe Admin::MessagesController do
  before(:each) do
    sign_in sign_in_user
  end

  context "when logged in as admin" do
    let(:sign_in_user) { FactoryGirl.create(:user, :is_admin => true) }

    describe "#new" do
      before(:each) do
        get :new
      end

      it "renders the 'new' template" do
        response.should render_template(:new)
      end
    end

    describe "#create" do
      before(:each) do
        ActionMailer::Base.deliveries = []
        @user_subscribed = FactoryGirl.create(:user, :profile => FactoryGirl.create(:profile,
                                                  :subscribed => true,
                                                  :experience => FactoryGirl.create(:experience)))
        post :create, :message => attributes
      end

      context "with valid params" do
        let(:attributes) { FactoryGirl.attributes_for(:message) }

        it "send message to user group" do
          Delayed::Worker.new.work_off
          ActionMailer::Base.deliveries.should_not be_empty
          ActionMailer::Base.deliveries.last.to.should eq([@user_subscribed.email])
        end

        it "redirects to the admin's dashboard'" do
          response.should redirect_to admin_root_path
        end
      end

      context "with invalid params" do
        let(:attributes) { { :subject => "" } }

        it "assigned message contains errors" do
          assigns(:message).should have_at_least(1).error_on(:subject)
        end

        it "re-renders the 'new' template" do
          response.should render_template("new")
        end
      end
    end
  end

  context "when logged in as user" do
    let(:sign_in_user) { FactoryGirl.create(:user) }

    describe "#new" do
      before(:each) do
        get :new
      end

      it "is forbidden" do
        response.status.should eq(403)
      end
    end
  end

  context "when not logged in" do
    let(:sign_in_user) { User.new }

    describe "#new" do
      before(:each) do
        get :new
      end

      it "redirects to the login page" do
        response.should redirect_to login_url
      end
    end
  end
end
