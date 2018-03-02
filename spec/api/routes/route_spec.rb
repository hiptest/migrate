require './lib/api/routing/routes'

module API
  module Routing

    RSpec.describe Routes::Route do

      describe '#level' do
        it 'returns the imbrication level of the route' do
          expect(Routes.lookup('projects').level).to eq(0)
          expect(Routes.lookup('scenarios').level).to eq(1)
          expect(Routes.lookup('testResult').level).to eq(3)
        end
      end

      describe '#segments' do
        it 'returns all the segments of the url path' do
          expect(Routes.lookup('projects').segments).to eq(['projects'])
          expect(Routes.lookup('scenarios').segments).to eq(['projects', 'scenarios'])
          expect(Routes.lookup('testResult').segments).
              to eq(['projects', 'test_runs', 'test_snapshots', 'test_results'])
        end
      end
    end
  end
end
