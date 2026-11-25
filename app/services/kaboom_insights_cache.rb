# Where the dashboard keeps the two AI answers (insights and win/loss). The controller reads
# and writes them; a conversation closing with an outcome clears them, so the next visit
# reads the sale instead of waiting out the TTL.
class KaboomInsightsCache
  def self.ai_insights_key(account_id)
    "kaboom:ai_insights:v6:#{account_id}"
  end

  def self.win_loss_key(account_id)
    "kaboom:win_loss:v5:#{account_id}"
  end

  def self.clear(account_id)
    Redis::Alfred.delete(ai_insights_key(account_id))
    Redis::Alfred.delete(win_loss_key(account_id))
  end
end
