class Contact < ActiveRecord::Base

  belongs_to :user, required: false
  delegate :admin?, :dnd_staff?, to: :user, allow_nil: true, prefix: true

  has_many :client_opportunity_matches
  has_many :services

  has_many :building_contacts, inverse_of: :contact, dependent: :destroy
  has_many :subgrantee_contacts, inverse_of: :contact, dependent: :destroy
  has_many :client_contacts, inverse_of: :contact, dependent: :destroy
  has_many :opportunity_contacts, inverse_of: :contact, dependent: :destroy
  has_many :client_opportunity_match_contacts, inverse_of: :contact, dependent: :destroy
  has_many :clients, through: :client_contacts
  has_many :buildings, through: :building_contacts
  has_many :subgrantees, through: :subgrantee_contacts

  has_many :events, class_name: 'MatchEvents::Base', inverse_of: :contact

  acts_as_paranoid
  has_paper_trail

  def full_name
    [first_name, last_name].compact.join " "
  end
  alias_method :name, :full_name

  def name_with_email
    "#{name} <#{email}>"
  end

  def has_user?
    user.present?
  end

  def hmis_managed?
    if id_in_data_source
      return true
    end
    return false
  end

  def self.text_search(text)
    return none unless text.present?

    query = "%#{text}%"
    where(
      arel_table[:first_name].matches(query)
      .or(arel_table[:last_name].matches(query))
      .or(arel_table[:email].matches(query))
      .or(arel_table[:phone].matches(query))
      .or(arel_table[:cell_phone].matches(query))
      .or(arel_table[:role].matches(query))
    )
  end
  
end