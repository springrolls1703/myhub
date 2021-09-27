import os
import pathlib
import unittest

from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager

def file_uri(filename):
    return pathlib.Path(os.path.abspath(filename)).as_uri()

driver  = webdriver.Chrome(ChromeDriverManager().install())

class WebpageTests(unittest.TestCase):
    def test_title(self):
        driver.get(file_uri("/Users/thangnguyen/Documents/git/myhub/.learning/cs50-web/lecture/testing-CI-CD/counter.html"))
        self.assertEqual(driver.title, "Counter")
    
    def test_increase(self):
        driver.get(file_uri("counter.html"))
        increase = driver.find_element_by_id("increase")
        increase.click()
        self.assertEqual(driver.find_element_by_tag_name("h1").text,"1")
    
    def test_decrease(self):
        driver.get(file_uri("counter.html"))
        decrease = driver.find_element_by_id("decrease")
        decrease.click()
        self.assertEqual(driver.find_element_by_tag_name("h1").text,"-1")

if __name__ == "__main__":
    unittest.main()
    
    