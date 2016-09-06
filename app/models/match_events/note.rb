module MatchEvents
  class Note < Base
    # Overall Match Notes are implemented as events
    validates :note, presence: true
    
    def name
      'Note added'
    end
    
    def remove_note!
      destroy
    end
    
  end
end