# frozen_string_literal: true

class WorkHistories::WorkVersionChangeComponent < WorkHistories::PaperTrailChangeBaseComponent
  # This apparently is a little quirk of ActionView::Component, and requires an
  # explicit #initialize method on each class.
  def initialize(**args)
    super
  end

  private

    def i18n_key
      'work_version'
    end

    def expected_item_type
      'WorkVersion'
    end

    def diff_id
      "change_diff_#{paper_trail_version.id}"
    end

    def action
      return translate('publish') if publish?

      super
    end

    def changed_attributes
      return [] unless update?

      diff.keys.map do |attr|
        WorkVersion.human_attribute_name(attr)
      end
    end

    def changed_attributes_truncated(count = 3)
      truncated = changed_attributes.first(count)
      remainder = changed_attributes.length - truncated.length
      truncated << translate('truncated_attributes', count: remainder) if 0 < remainder
      truncated.join(', ')
    end

    # @todo make this its own component?
    def diff_presenter
      @diff_presenter ||= DiffPresenter.new(diff)
    end

    def publish?
      paper_trail_version.event == 'update' &&
        paper_trail_version.object_changes.fetch('aasm_state', []).last.to_s == WorkVersion::STATE_PUBLISHED.to_s
    end

    def update?
      super && !publish?
    end

    def diff
      @diff ||= WorkVersionChangeDiff.call(paper_trail_version)
    end
end
