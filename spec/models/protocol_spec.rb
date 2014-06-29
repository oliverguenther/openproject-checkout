require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpenProject::Checkout::Protocol, :type => :model do

  let(:project) { FactoryGirl.create(:project, is_public: true) }
  let(:role) { FactoryGirl.create(:role, permissions: [:browse_repository]) }
  let(:user) { FactoryGirl.create(:user) }
  let!(:member) { FactoryGirl.create(:member, user: user, project: project, roles: [role]) }
  let(:admin) { FactoryGirl.create(:admin) }
  let!(:repo) { FactoryGirl.create(:svn_repository, project: project, url: 'http://example.com/svn/testrepo') }

  before(:each) do
    project.enabled_module_names = project.enabled_module_names << "repository"
    setup_subversion_protocols
  end

  after(:each) do
    User.current = nil
  end

  it "should use regexes for generated URL" do
    protocol = repo.checkout_protocols.find{|r| r.protocol == "SVN+SSH"}
    expect(protocol.url).to eql "svn+ssh://svn.foo.bar/svn/testrepo"
  end

  it "should resolve access properties" do
    protocol = repo.checkout_protocols.find{|r| r.protocol == "Subversion"}
    expect(protocol.access).to eql "permission"
    expect(protocol.access_rw(admin)).to eql "read+write"

    User.current = user
    expect(protocol.access_rw(user)).to eql "read-only"
  end

  it "should display the checkout command" do
    subversion = repo.checkout_protocols.find{|r| r.protocol == "Subversion"}
    svn_ssh = repo.checkout_protocols.find{|r| r.protocol == "SVN+SSH"}

    expect(subversion.command).to eql "svn checkout"
    expect(svn_ssh.command).to eql "svn co"
  end

  it "should respect display login settings" do
    protocols = repo.checkout_protocols

    User.current.login = "der_baer"
    repo.checkout_overwrite = "1"
    repo.checkout_protocols = protocols

    protocol = repo.checkout_protocols.find{|r| r.protocol == "Root"}

    protocol.display_login = '0'
    expect(protocol.url).to eql "http://example.com/svn/testrepo"

    protocol.display_login = '1'
    expect(protocol.url).to eql "http://der_baer@example.com/svn/testrepo"
  end

end
