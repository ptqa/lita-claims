require "spec_helper"

describe Lita::Handlers::Claims, lita_handler: true do
  describe 'routes' do
    it { routes_command('claim property').to :create }
    it { routes_command('claim property environment').to :create }

    it { routes_command('who claimed property').to :exists? }
    it { routes_command('who claimed property environment').to :exists? }
  end

  describe 'creating claims' do
    it 'replies that the claim was made' do
      send_command 'claim property_x'
      expect(replies.last).to eq('property_x was claimed by Test User.')
      expect(Claim.exists?('property_x')).to be_true
    end

    it 'replies that the claim was made for a non-default environment' do
      send_command 'claim property_x environment_y'
      expect(replies.last).to eq('property_x (environment_y) was claimed by Test User.')
      expect(Claim.exists?('property_x', 'environment_y')).to be_true
    end

    it 'replies that a claim could not be made because it already exists' do
      Claim.create('property', 'Test User')
      send_command 'claim property'
      expect(replies.last).to eq('Could not claim property - already claimed by Test User.')
    end

    it 'replies that a claim could not be made for a non-default environment because it already exists' do
      Claim.create('property', 'Test User', 'env')
      send_command 'claim property env'
      expect(replies.last).to eq('Could not claim property (env) - already claimed by Test User.')
    end
  end

  describe 'check if property has been claimed' do
    it 'replies who claimed a property' do
      Claim.create('property_x', 'claimer')
      send_command 'who claimed property_x'
      expect(replies.last).to eq('property_x is currently claimed by claimer.')
    end

    it 'replies who claimed a property with environment' do
      Claim.create('property_x', 'claimer', 'some_env')
      send_command 'who claimed property_x some_env'
      expect(replies.last).to eq('property_x (some_env) is currently claimed by claimer.')
    end

    it 'replies that a property has not been claimed' do
      send_command 'who claimed property_x'
      expect(replies.last).to eq('property_x has not been claimed.')
    end

    it 'replies that a property has not been claimed with environment' do
      send_command 'who claimed property_x some_env'
      expect(replies.last).to eq('property_x (some_env) has not been claimed.')
    end
  end
end
