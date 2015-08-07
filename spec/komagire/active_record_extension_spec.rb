require 'spec_helper'

describe Komagire::ActiveRecordExtension do
  create_temp_table :tags do |t|
    t.string :name
  end

  class Tag < ActiveRecord::Base
  end

  describe '#composed_of_komagire_key_list' do
    create_temp_table :post_names do |t|
      t.string :tag_names
    end

    class PostName < ActiveRecord::Base
      composed_of_komagire_key_list :tags, :tag_names, 'Tag', :name, komagire: {delimiter: '|'}
    end

    let!(:ruby) { Tag.create(id: 1, name: 'ruby') }
    let!(:perl) { Tag.create(id: 2, name: 'perl') }
    let!(:java) { Tag.create(id: 3, name: 'java') }

    let(:post) { PostName.new }

    it 'empty' do
      post.tags = ''
      expect(post.tag_names).to eq '|'
      post.save!
      expect(post.tag_names).to eq '|'
    end

    it 'should ignore not exist key' do
      post.tags = 'python|perl'
      expect(post.tag_names).to eq '|perl|'
      post.save!
      expect(post.tag_names).to eq '|perl|'
    end

    it 'should ignore duplicate key' do
      post.tags = 'ruby|perl|ruby'
      expect(post.tag_names).to eq '|perl|ruby|'
      post.save!
      expect(post.tag_names).to eq '|perl|ruby|'
    end

    it 'should convert from string' do
      post.tags = 'ruby|perl|java'
      expect(post.tag_names).to eq '|java|perl|ruby|'
      post.save!
      expect(post.tag_names).to eq '|java|perl|ruby|'
    end

    it 'should convert from Komagire::KeyList' do
      list = Komagire::KeyList.new('Tag', :name, 'ruby|java', delimiter: '|')
      post.tags = list
      expect(post.tag_names).to eq '|java|ruby|'
      post.save!
      expect(post.tag_names).to eq '|java|ruby|'
    end

    it 'should convert from Array of String' do
      post.tags = ['java', 'perl']
      expect(post.tag_names).to eq '|java|perl|'
      post.save!
      expect(post.tag_names).to eq '|java|perl|'
    end

    it 'should convert from Array of Tag' do
      post.tags = [ruby, perl]
      expect(post.tag_names).to eq '|perl|ruby|'
      post.save!
      expect(post.tag_names).to eq '|perl|ruby|'
    end

    it 'should convert from ActiveRecord::Relation' do
      post.tags = Tag.where(id: [1])
      expect(post.tag_names).to eq '|ruby|'
      post.save!
      expect(post.tag_names).to eq '|ruby|'
    end
  end

  describe '#composed_of_komagire_id_list' do
    create_temp_table :post_ids do |t|
      t.string :tag_ids
    end

    class PostId < ActiveRecord::Base
      composed_of_komagire_id_list :tags, :tag_ids, 'Tag'
    end

    let!(:ruby) { Tag.create(id: 1, name: 'ruby') }
    let!(:perl) { Tag.create(id: 2, name: 'perl') }
    let!(:java) { Tag.create(id: 3, name: 'java') }

    let(:post) { PostId.new }

    it 'empty' do
      post.tags = ''
      expect(post.tag_ids).to eq ','
      post.save!
      expect(post.tag_ids).to eq ','
    end

    it 'should ignore not exist id' do
      post.tags = '100,1'
      expect(post.tag_ids).to eq ',1,'
      post.save!
      expect(post.tag_ids).to eq ',1,'
    end

    it 'should ignore duplicate id' do
      post.tags = '1,2,1'
      expect(post.tag_ids).to eq ',1,2,'
      post.save!
      expect(post.tag_ids).to eq ',1,2,'
    end

    it 'should convert from string' do
      post.tags = '1,2,3'
      expect(post.tag_ids).to eq ',1,2,3,'
      post.save!
      expect(post.tag_ids).to eq ',1,2,3,'
    end

    it 'should convert from Komagire::IdList' do
      list = Komagire::IdList.new('Tag', '1,3', delimiter: ',')
      post.tags = list
      expect(post.tag_ids).to eq ',1,3,'
      post.save!
      expect(post.tag_ids).to eq ',1,3,'
    end

    it 'should convert from Array of String' do
      post.tags = ['3', '2']
      expect(post.tag_ids).to eq ',2,3,'
      post.save!
      expect(post.tag_ids).to eq ',2,3,'
    end

    it 'should convert from Array of Integer' do
      post.tags = [3, 2]
      expect(post.tag_ids).to eq ',2,3,'
      post.save!
      expect(post.tag_ids).to eq ',2,3,'
    end

    it 'should convert from Array of Tag' do
      post.tags = [ruby, perl]
      expect(post.tag_ids).to eq ',1,2,'
      post.save!
      expect(post.tag_ids).to eq ',1,2,'
    end

    it 'should convert from ActiveRecord::Relation' do
      post.tags = Tag.where(id: [1])
      expect(post.tag_ids).to eq ',1,'
      post.save!
      expect(post.tag_ids).to eq ',1,'
    end
  end

  describe '#composed_of_komagire_id_list with ActiveHash' do
    context "when Id type is integer" do
      class AhTag < ActiveHash::Base
        self.data = [
          {id: 1, name: 'ruby'},
          {id: 2, name: 'perl'},
          {id: 3, name: 'java'},
        ]
      end

      create_temp_table :post_ahs do |t|
        t.string :tag_ids
      end

      class PostAh < ActiveRecord::Base
        composed_of_komagire_id_list :tags, :tag_ids, 'AhTag', komagire: {delimiter: ':'}
      end

      let(:post) { PostAh.new }

      it 'empty' do
        post.tags = ''
        expect(post.tag_ids).to eq ':'
        post.save!
        expect(post.tag_ids).to eq ':'
      end

      it 'should ignore not exist id ' do
        post.tags = '100:1'
        expect(post.tag_ids).to eq ':1:'
        post.save!
        expect(post.tag_ids).to eq ':1:'
      end

      it 'should ignore duplicate id' do
        post.tags = '1:2:1'
        expect(post.tag_ids).to eq ':1:2:'
        post.save!
        expect(post.tag_ids).to eq ':1:2:'
      end

      it 'should convert from string' do
        post.tags = '1:2:3'
        expect(post.tag_ids).to eq ':1:2:3:'
        post.save!
        expect(post.tag_ids).to eq ':1:2:3:'
      end

      it 'should convert from Komagire::IdList' do
        list = Komagire::IdList.new('AhTag', '1:3', delimiter: ':')
        post.tags = list
        expect(post.tag_ids).to eq ':1:3:'
        post.save!
        expect(post.tag_ids).to eq ':1:3:'
      end

      it 'should convert from Array of String' do
        post.tags = ['3', '2']
        expect(post.tag_ids).to eq ':2:3:'
        post.save!
        expect(post.tag_ids).to eq ':2:3:'
      end

      it 'should convert from Array of Integer' do
        post.tags = [3, 2]
        expect(post.tag_ids).to eq ':2:3:'
        post.save!
        expect(post.tag_ids).to eq ':2:3:'
      end

      it 'should convert from Array of Tag' do
        post.tags = [AhTag.find(1)]
        expect(post.tag_ids).to eq ':1:'
        post.save!
        expect(post.tag_ids).to eq ':1:'
      end
    end

    context 'when Id type is string' do
      class ProductType < ActiveHash::Base
        include ActiveHash::Enum
        self.data = [
          {id: 'bacon', name: 'Bacon'},
          {id: 'lettuce', name: 'Lettuce'},
          {id: 'tomato', name: 'Tomato'},
        ]
        enum_accessor :id
      end

      create_temp_table :products do |t|
        t.string :product_type_ids
      end

      class Product < ActiveRecord::Base
        composed_of_komagire_id_list :product_types, :product_type_ids, 'ProductType'
      end

      let(:product) { Product.new }

      it 'should be ignore not exist key' do
        product.product_types = "peamon"
        expect(product.product_type_ids).to eq ','
        product.save!
        expect(product.product_type_ids).to eq ','
      end

      it 'should be convertible from string' do
        product.product_types = "bacon,tomato"
        expect(product.product_type_ids).to eq ',bacon,tomato,'
        product.save!
        expect(product.product_type_ids).to eq ',bacon,tomato,'
      end

      it 'should be convertible from Array of Strings' do
        product.product_types = ['bacon', 'tomato']
        expect(product.product_type_ids).to eq ',bacon,tomato,'
        product.save!
        expect(product.product_type_ids).to eq ',bacon,tomato,'
      end

      it 'should be convertible from Array of ProductType' do
        product.product_types = [ProductType::BACON, ProductType::TOMATO]
        expect(product.product_type_ids).to eq ',bacon,tomato,'
        product.save!
        expect(product.product_type_ids).to eq ',bacon,tomato,'
      end
    end
  end
end
