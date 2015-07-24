require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Macros" do
  include ERB::Util
  include ApplicationHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper

  let(:project) { FactoryGirl.create(:project) }
  let(:svn_repository) { FactoryGirl.create(:repository_subversion, project: project,
                                            url: 'file:///tmp/test/svn_repo') }

  before(:each) do
    project.enabled_module_names = project.enabled_module_names << "repository"
    Setting.checkout_display_command_Subversion = '0'
    setup_subversion_protocols
    @project = project
    @project.repository = svn_repository
    @project.save!
  end


  it "should display default checkout url" do
    text = "{{repository}}"

    url = "file:///tmp/test/svn_repo"
    expect(format_text(text)).to eql "<p><a href=\"#{url}\">#{url}</a></p>"
  end

  it "should display forced checkout url" do
    text = "{{repository(svn+ssh)}}"

    url = 'svn+ssh://svn.foo.bar/svn/svn_repo'
    expect(format_text(text)).to eql "<p><a href=\"#{url}\">#{url}</a></p>"
  end

  it "should fail without set project" do
    @project = nil

    text = "{{repository(svn+ssh)}}"
    error = Nokogiri::HTML(format_text(text)).css('.flash.error')
    message = "Error executing the macro repository (Checkout protocol svn+ssh not found)"

    expect(error.inner_text.strip).to eql message
  end

  it "should display checkout url from stated project" do
    @project = nil
    text = "{{repository(#{project.name}:svn+ssh)}}"

    url = 'svn+ssh://svn.foo.bar/svn/svn_repo'
    expect(format_text(text)).to eql "<p><a href=\"#{url}\">#{url}</a></p>"
  end

  it "should display command" do
    Setting.checkout_display_command_Subversion = '1'

    text = "{{repository(svn+ssh)}}"
    url = 'svn+ssh://svn.foo.bar/svn/svn_repo'
    expect(format_text(text)).to eql "<p>svn co <a href=\"#{url}\">#{url}</a></p>"
  end
end
