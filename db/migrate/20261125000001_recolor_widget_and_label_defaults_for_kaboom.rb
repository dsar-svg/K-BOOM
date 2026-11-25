# frozen_string_literal: true

# Widgets and labels carried Chatwoot's #1f93ff as their column default, so every one
# created without an explicit colour came out in the upstream blue rather than ours.
#
# The data update deliberately touches only rows still sitting on that old default.
# A colour anyone picked by hand is a choice, not a leftover, and stays untouched.
class RecolorWidgetAndLabelDefaultsForKaboom < ActiveRecord::Migration[7.1]
  OLD_COLOR = '#1f93ff'
  NEW_COLOR = '#344ddd'

  def up
    change_column_default :channel_web_widgets, :widget_color, from: OLD_COLOR, to: NEW_COLOR
    change_column_default :labels, :color, from: OLD_COLOR, to: NEW_COLOR

    recolor(OLD_COLOR, NEW_COLOR)
  end

  def down
    change_column_default :channel_web_widgets, :widget_color, from: NEW_COLOR, to: OLD_COLOR
    change_column_default :labels, :color, from: NEW_COLOR, to: OLD_COLOR

    # Rolling back cannot tell a row this migration repainted from one somebody chose
    # to set to NEW_COLOR afterwards; both go back to OLD_COLOR.
    recolor(NEW_COLOR, OLD_COLOR)
  end

  private

  # Raw SQL on purpose: a migration should not depend on model classes that may be
  # renamed, scoped or validated differently by the time it runs.
  def recolor(from, to)
    execute <<~SQL.squish
      UPDATE channel_web_widgets
         SET widget_color = #{connection.quote(to)}
       WHERE widget_color = #{connection.quote(from)}
    SQL

    execute <<~SQL.squish
      UPDATE labels
         SET color = #{connection.quote(to)}
       WHERE color = #{connection.quote(from)}
    SQL
  end
end
