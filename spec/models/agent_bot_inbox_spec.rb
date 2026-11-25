require 'rails_helper'

RSpec.describe AgentBotInbox do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:inbox_id) }
    it { is_expected.to validate_presence_of(:agent_bot_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:agent_bot) }
    it { is_expected.to belong_to(:inbox) }
  end

  # after_*_commit callbacks share one chain and ActiveSupport keys them by the filter, so two
  # hooks pointing at the same method name leave only the last one registered. Both of these
  # used to be :release_conversations, which meant destroying the record released nothing.
  describe 'releasing the conversations the bot still holds' do
    let(:agent_bot_inbox) { create(:agent_bot_inbox) }

    it 'enqueues the job when the record is destroyed' do
      agent_bot_inbox
      expect { agent_bot_inbox.destroy! }
        .to have_enqueued_job(Conversations::ReleaseBotJob)
        .with(agent_bot_inbox.inbox_id, agent_bot_inbox.agent_bot_id)
    end

    it 'enqueues the job when the bot is set inactive' do
      agent_bot_inbox
      expect { agent_bot_inbox.update!(status: :inactive) }
        .to have_enqueued_job(Conversations::ReleaseBotJob)
        .with(agent_bot_inbox.inbox_id, agent_bot_inbox.agent_bot_id)
    end

    it 'leaves the conversations alone on an update that does not deactivate the bot' do
      agent_bot_inbox
      expect { agent_bot_inbox.update!(status: :active) }
        .not_to have_enqueued_job(Conversations::ReleaseBotJob)
    end
  end
end
