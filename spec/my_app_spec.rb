# Copied from https://github.com/benbalter/add-to-org/blob/master/spec/add-to-org_spec.rb
require "spec_helper"

describe "logged in user" do

  include Rack::Test::Methods

  def app
    AddToOrg::App
  end

  before do
    @user = make_user('login' => 'benbaltertest')
    login_as @user
  end

  it "denies acccess to invalid users" do
    with_env "GITHUB_ORG_ID", "some_org" do
      stub_request(:get, "https://api.github.com/orgs/some_org/members/benbaltertest").
      to_return(:status => 404)

      stub_request(:get, "https://api.github.com/user/emails").
      to_return(:status => 200, :body => fixture("invalid_emails.json"), :headers => { 'Content-Type'=>'application/json' })

      get "/"
      expect(last_response.status).to eql(403)
      expect(last_response.body).to match(/We're unable to verify your eligibility at this time/)
    end
  end

  it "adds valid users" do
    with_env "GITHUB_ORG_ID", "some_org" do
      stub_request(:get, "https://api.github.com/orgs/some_org/members/benbaltertest").
      to_return(:status => 404)

      stub_request(:get, "https://api.github.com/user/emails").
      to_return(:status => 200, :body => fixture("emails.json"), :headers => { 'Content-Type'=>'application/json' })

      stub = stub_request(:put, "https://api.github.com/teams/memberships/benbaltertest").
      to_return(:status => 204)

      get "/foo"
      expect(stub).to have_been_requested
      expect(last_response.status).to eql(200)
      expect(last_response.body).to match(/confirm your invitation to join the organization/)
      expect(last_response.body).to match(/https:\/\/github.com\/orgs\/some_org\/invitation/)
      expect(last_response.body).to match(/\?return_to=https:\/\/github.com\/foo/)
    end
  end
end
