require 'rails_helper'

RSpec.describe Score, type: :model do
  it 'requires initials' do
    expect(subject).to have(2).errors_on(:initials)
  end

  it 'requires value' do
    expect(subject).to have(2).errors_on(:value)
  end

  it 'disallows negative value' do
    subject.value = -1
    expect(subject).to have(1).error_on(:value)
  end

  it 'disallows zero value' do
    subject.value = 0
    expect(subject).to have(1).error_on(:value)
  end

  it 'disallows rude words for initials' do
    Score::BAD_WORDS.each do |initials|
      subject.initials = initials
      expect(subject).to have(1).error_on(:initials)
    end
  end

  it 'disallows initials with fewer than 3 characters' do
    subject.initials = 'a'
    expect(subject).to have(1).error_on(:initials)
    subject.initials = 'ab'
    expect(subject).to have(1).error_on(:initials)
  end

  it 'disallows initials with more than 3 characters' do
    subject.initials = 'abcd'
    expect(subject).to have(1).error_on(:initials)
  end

  it 'capitalizes initials on save' do
    subject = build(:score)
    subject.initials = 'abc'
    subject.save!
    expect(subject.reload.initials).to eq('ABC')
  end

  it 'allows multiple scores from different IPs within a minute' do
    score1 = create(:score, ip_address: '1.2.3.4')
    score2 = build(:score, ip_address: '8.9.4.5')
    expect(score2.save).to eq(true)
  end

  it 'allows multiple scores from the same IP at least a minute apart' do
    score1 = create(:score, ip_address: '1.2.3.4', created_at: 90.seconds.ago)
    score2 = build(:score, ip_address: score1.ip_address)
    expect(score2.save).to eq(true)
  end

  it 'disallows multiple scores from the same IP within a minute' do
    score1 = create(:score, ip_address: '1.2.3.4')
    score2 = build(:score, ip_address: score1.ip_address)
    expect(score2.save).to eq(false)
    expect(score2.errors[:base]).to_not be_empty
  end

  describe 'rank' do
    it 'returns same rank for scores with the same value' do
      score1 = create(:score, value: 3000)
      score2 = create(:score, value: 3000)
      expect(score1.rank).to eq(score2.rank)
    end

    it 'returns lower number for score with higher value' do
      score1 = create(:score, value: 5000)
      score2 = create(:score, value: 4000)
      expect(score1.rank).to be < score2.rank
    end
  end

  describe 'last_seven_days' do
    it 'includes score made today' do
      score = create(:score)
      expect(Score.last_seven_days).to include(score)
    end

    it 'excludes score made last week' do
      score = create(:score, created_at: 1.week.ago)
      expect(Score.last_seven_days).to_not include(score)
    end

    it 'excludes score made tomorrow' do
      score = create(:score, created_at: 1.day.from_now)
      expect(Score.last_seven_days).to_not include(score)
    end
  end

  describe 'last_thirty_days' do
    it 'includes score made today' do
      score = create(:score)
      expect(Score.last_thirty_days).to include(score)
    end

    it 'excludes score made 31 days ago' do
      score = create(:score, created_at: 31.days.ago)
      expect(Score.last_thirty_days).to_not include(score)
    end

    it 'excludes score made tomorrow' do
      score = create(:score, created_at: 1.day.from_now)
      expect(Score.last_thirty_days).to_not include(score)
    end
  end
end
