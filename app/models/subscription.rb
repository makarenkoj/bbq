class Subscription < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :event, presence: true
  validates :user_name, presence: true, unless: -> { user.present? }
  validates :user_email, presence: true,
            format: /\A[a-zA-Z0-9\-_.]+@[a-zA-Z0-9\-_.]+\z/, unless: -> { user.present? }
  validates :user, uniqueness: {scope: :event_id}, if: -> { user.present? }
  validates :user_email, uniqueness: {scope: :event_id}, unless: -> { user.present? }

  validate :user_organizer, on: :create, if: -> { user.present? }
  #валидация на залогиненый емаил
  validate :user_email_uniq, on: :create, unless: -> { user.present? }

  def user_name
    if user.present?
      user.name
    else
      super
    end
  end

  def user_email
    if user.present?
      user.email
    else
      super
    end
  end
end

def user_organizer
  errors.add(:user_id, I18n.t('errors.organize_subscribe')) if user == event.user
end

def user_email_uniq
  errors.add(:user_email, I18n.t('errors.user_email')) if User.all.where(email: user_email).any?
end
