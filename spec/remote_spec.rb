require 'spec_helper'

describe "remote requests" do
  let(:endpoint){ ENV['REMOTE_ENDPOINT'] }
  let(:auth_token){ ENV['AUTH_TOKEN'] }

  let(:client_id) { ENV['CLIENT_ID'] }
  let(:client_secret) { ENV['CLIENT_SECRET'] }

  before do
    pending "REMOTE_ENDPOINT required for remote spec" unless endpoint
    pending "AUTH_TOKEN required for remote spec" unless auth_token
  end
  let!(:client){ Attune::Client.new(endpoint: endpoint, auth_token: auth_token) }

  it "can request an auth_token given a client id and secret" do
    pending "CLIENT_ID required for get_auth_token spec" unless client_id
    pending "CLIENT_SECRET required for get_auth_token spec" unless client_secret
    token = client.get_auth_token(client_id, client_secret)
    token.should =~ /[a-z0-9\-]+/
  end

  it "can create an anonymous user" do
    id = client.create_anonymous(user_agent: 'Mozilla/5.0')
    id.should =~ /[a-z0-9\-]+/
  end

  it "can create an anonymous user with an id" do
    id = client.create_anonymous(id: '123456', user_agent: 'Mozilla/5.0')
    id.should == '123456'
  end

  it "can bind an anonymous user" do
    id = client.create_anonymous(id: '123456', user_agent: 'Mozilla/5.0')
    client.bind(id, '654321')
  end

  let(:entities){ [202875,202876,202874,202900,202902,202898,202905,200182,200181,185940,188447,185932,190589,1238689589] }
  describe "get_rankings" do
    before(:each) do
      id = client.create_anonymous(id: '123456', user_agent: 'Mozilla/5.0')
      client.bind(id, '654321')
      @result = client.get_rankings(id: '123456', view: 'b/mens-pants', collection: 'products', entities: entities)
    end
    it "can get ranked entities" do
      @result[:entities].should be_an Array
      @result[:entities].sort.should == entities.map(&:to_s).sort
    end
    specify { expect(@result[:headers]).to be_a Hash }
    specify { expect(@result[:headers]).to have_key "attune-ranking" }
    specify { expect(@result[:headers]).to have_key "attune-cell" }
  end

  describe "multi_get_rankings" do
    before(:each) do
      id = client.create_anonymous(id: '123456', user_agent: 'Mozilla/5.0')
      client.bind(id, '654321')
      @results = client.multi_get_rankings([id: '123456', view: 'b/mens-pants', collection: 'products', entities: entities])
    end
    it "can batch get rankings" do
      @results[:entities].should be_an Array
      result, = *@results[:entities]
      result.sort.should == entities.map(&:to_s).sort
    end
    specify { expect(@results[:headers]).to be_a Hash }
    specify { expect(@results[:headers]).to have_key "attune-ranking" }
    specify { expect(@results[:headers]).to have_key "attune-cell" }
  end
end
