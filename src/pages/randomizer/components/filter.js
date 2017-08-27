// @flow
import * as React from 'react'
import { Button } from 'semantic-ui-react'

type PROPS = {
  updateFilter: string => void,
  selectedFilter: 'all' | 'fav' | 'my'
}
type FilterStatelessComponent = PROPS => React.Element<*>

const Filter: FilterStatelessComponent = ({ updateFilter, selectedFilter }) => {
  return (
    <Button.Group fluid>
      <Button
        active={selectedFilter === 'all'}
        onClick={() => updateFilter('all')}
      >
        All
      </Button>
      <Button
        active={selectedFilter === 'fav'}
        onClick={() => updateFilter('fav')}
      >
        Favs
      </Button>
      <Button
        active={selectedFilter === 'my'}
        onClick={() => updateFilter('my')}
      >
        Mine
      </Button>
    </Button.Group>
  )
}

export default Filter
