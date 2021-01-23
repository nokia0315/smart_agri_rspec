require 'rails_helper'

RSpec.describe 'genreモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { genre.valid? }

    let(:admin) { create(:admin) }
    let!(:genre) { build(:genre, admin_id: admin.id) }

    context 'nameカラム' do
      it '空欄でないこと' do
        genre.name = ''
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'adminモデルとの関係' do
      it 'N:1となっている' do
        expect(genre.reflect_on_association(:admin).macro).to eq :belongs_to
      end
    end
  end
end