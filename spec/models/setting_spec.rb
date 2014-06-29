require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Setting, :type => :model do
  before(:each) do
    Setting.stub(:default_language).and_return('en')
    Setting.stub(:checkout_display_checkout_info).and_return('everywhere')
  end

  it "should recognize checkout methods" do
    expect(Setting.checkout_display_checkout_info).to eql Setting.plugin_openproject_checkout['display_checkout_info']
    expect(Setting.checkout_display_checkout_info).to eql Setting.plugin_openproject_checkout[:display_checkout_info]
  end
end
