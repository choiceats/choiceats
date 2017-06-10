/* global fetch */
// @flow
import endpoints from './endpoints'

const baseUrl = `${endpoints.protocol}://${endpoints.url}:${endpoints.port}`

export const getUser = () => {
  if (!window.localStorage) return null
  return {
    email: window.localStorage.getItem('email'),
    name: window.localStorage.getItem('name'),
    token: window.localStorage.getItem('accessToken'),
    userId: window.localStorage.getItem('userId')
  }
}

export const setUser = (user: any) => {
  if (!window.localStorage) return null
  window.localStorage.setItem('accessToken', user.token)
  window.localStorage.setItem('email', user.email)
  window.localStorage.setItem('name', user.name)
  window.localStorage.setItem('userId', user.userId)

  return user
}

export const login = (email: string, password: string) => {
  return fetch(`${baseUrl}/auth`, {
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
    setUser(responseJson)
    return responseJson
  })
}

export const clearUser = () => {
  if (!window.localStorage) return null
  window.localStorage.removeItem('accessToken')
  window.localStorage.removeItem('email')
  window.localStorage.removeItem('name')
  window.localStorage.removeItem('userId')
}

type RegisterParams = {
  email: string;
  firstName: string;
  lastName: string;
  password: string;
}

export const register = (params: RegisterParams) => {
  return fetch(`${baseUrl}/user`, {
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
