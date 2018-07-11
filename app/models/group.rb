#:nodoc:
class Group < ApplicationRecord
  validates :name, presence: true
  validates :category, presence: true
  validates :year, presence: true

  enum category: { board: 1, committee: 2, moot: 3, other: 4 }

  has_many :activities, :foreign_key => :organized_by

  has_many :group_members,
           :dependent => :destroy
  has_many :members,
           :through => :group_members

  is_impressionable

  def positions
    return ['chairman', 'secretary', 'treasurer', 'internal', 'external', 'education'] if board?
    return (['chairman', 'treasurer', 'board'] + Settings['additional_positions.committee'] + group_members.select(:position).order(:position).uniq.map(&:position)).compact.uniq if committee?
    return (['chairman', 'secretary', 'treasurer'] + Settings['additional_positions.moot'] + group_members.select(:position).order(:position).uniq.map(&:position)).compact.uniq if moot?
    return ['chairman', 'treasurer']
  end

  def members
    group_members.sort do |a, b|
      if positions.index(a.position).nil? && positions.index(b.position).nil?
        a.name <=> b.name
      elsif positions.index(b.position).nil?
        -1
      elsif positions.index(a.position).nil?
        1
      elsif positions.index(a.position) == positions.index(b.position)
        a.name <=> b.name
      else
        positions.index(a.position) <=> positions.index(b.position)
      end
    end
  end

  def self.years
    Group.pluck(:year).uniq.map { |year| ["#{ year } - #{ 1 + year }", year] }.to_h
  end
end
