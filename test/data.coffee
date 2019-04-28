exports = module.exports = {}

exports.singleInstanceNotFound =
{
  result: {
    value: {},
    type: 'object'
  }
}

exports.singleInstance =
{
  result: {
    value: {
      node: {},
      isFragment: false,
      state: {},
      props: {}
    },
    type: 'object'
  }
}

exports.multipleInstancesNotFound =
{
  result: {
    value: [],
    type: 'array'
  }
}

exports.multipleInstances =
{
  result: {
    value: [
      {
        node: {},
        isFragment: false,
        state: {},
        props: {}
      },
      {
        node: {},
        isFragment: false,
        state: {},
        props: {}
      },
    ],
    type: 'array'
  }
}
