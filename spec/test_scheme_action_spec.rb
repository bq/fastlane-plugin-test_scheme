describe Fastlane::Actions::TestSchemeAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The test_scheme plugin is working!")

      Fastlane::Actions::TestSchemeAction.run(nil)
    end
  end
end
