/* global fetch */
// @flow
export const getToken = () => {
  return window.localStorage.getItem('accessToken')
}

export const setToken = (token: string) => {
  return window.localStorage.setItem('accessToken', token)
}

export const login = (email: string, password: string) => {
  return fetch('http://localhost:4000/auth', {
    method: 'post',
    headers: {
      'content-type': 'application/json'
    },
    body: JSON.stringify({
      email,
      password
    })
  })
  .then(response => {
    if (response.status === 401) {
      throw Error('Bad password!')
    }

    return response.json()
  })
  .then(responseJson => {
    setToken(responseJson.token)
  })
}

export const clearToken = () => {
  window.localStorage.removeItem('accessToken')
}

type RegisterParams = {
  email: string;
  firstName: string;
  lastName: string;
  password: string;
}

export const register = (params: RegisterParams) => {
  return fetch('http://localhost:4000/user', {
    method: 'post',
    headers: {
      'content-type': 'application/json'
    },
    body: JSON.stringify({
      email: params.email,
      firstName: params.firstName,
      lastName: params.lastName,
      password: params.password
    })
  })
  .then(response => {
    if (response.status === 401) {
      throw Error('Who are you?')
    }
    return response.json()
  })
  .then(responseJson => {
    console.log('login now?')
  })
}
