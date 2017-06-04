const webdriver = require('selenium-webdriver')

const { until } = webdriver
const driver = new webdriver.Builder()
  .forBrowser('chrome')
  .build()

driver.get('localhost:3000')
driver.wait(until.titleIs('sss'), 1000)
driver.quit()
