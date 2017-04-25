'''
Created on Apr 25, 2017

@author: intothelight
'''
import requests
import time
import re
import urllib
import io
import logging
import BeautifulSoup
import os
import sys
import random
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException


# Needed directories
saved_html_files_location = "/Users/intothelight/nycdatascience/tmp/data_dump/scraper_html_files"
processed_files_location = "/Users/intothelight/nycdatascience/tmp/data_dump/scraper_data_files"
log_files_location = "/Users/intothelight/nycdatascience/tmp/data_dump/scraper_log_files"
app_name = "html_processor"

# create needed directories
if not os.path.exists(log_files_location):
    os.makedirs(log_files_location)
    
if not os.path.exists(saved_html_files_location):
    os.makedirs(saved_html_files_location)

if not os.path.exists(processed_files_location):
    os.makedirs(processed_files_location)
    
# start logging
logfile = time.strftime("%Y-%m-%d")
full_logfilepath = "{}/{}__{}.log".format(log_files_location,logfile,app_name)
logging.basicConfig(filename=full_logfilepath, format="%(asctime)s - %(levelname)s: %(message)s", datefmt="%m/%d/%Y %I:%M:%S %p", level=logging.DEBUG)

logging.info("Begin logging")


urls_to_scan = {}
html_files_to_process = {}
final_csv_files = {}

# these urls to be loaded or scrapped
urls_to_scan = {"https://www.unam.mx": "https://www.unam.mx" }



def check_url(url):
    response_code = requests.head(url)
    logging.info("url:%s , status code:%s", url ,response_code.status_code)
    return response_code.status_code < 400

scanner_url = "http://urlquery.net/api/v2/post.php?url=https://www.va.gov"
scanner_primer_url = "http://urlquery.net/index.php"
scanner_report_url = "http://urlquery.net/report.php?id="
website_url = "https://www.va.gov"

    
#session = requests.session()
session = webdriver.PhantomJS(executable_path="/Users/intothelight/anaconda/pkgs/phantomjs-2.1.1-0/bin/phantomjs")
session.set_window_size(1439, 799)

# Here we would start our loop to process urls to be scanned
# BEGIN SCAN LOOP
website_url = random.choice(urls_to_scan.keys())
logging.info("Selected url to scan: %s", website_url)


if check_url(scanner_primer_url):
    logging.info("Scanner is up")
else:
    logging.error("Scanner not available")
    session.quit()
    sys.exit()
    
    
if check_url(website_url):
    logging.info("Target site is up")
else:
    logging.warn("Target site not available")
    session.quit()
    sys.exit()


session.get(scanner_primer_url)
url_box_id = "url"
url_btn_id = "url-submit"
url_text_box = session.find_element_by_id(url_box_id)
url_text_box.send_keys(website_url)
url_submit_btn = session.find_element_by_id(url_btn_id)
url_submit_btn.click()
html_ready_to_save = False
waiting = True
wait_time = 30
report_status_id = "status"
while waiting:

    time.sleep(wait_time)
    logging.info("Current browser url:%s", session.current_url)
    matchObj = re.search(r"report",session.current_url, re.M|re.I)
    if matchObj:
        logging.info("Report url was matched")
        try:
            cell = session.find_element_by_id(report_status_id)
            logging.info("Status element found in html")
            matchReportObj = re.search(r"Report complete",cell.text, re.M|re.I)
            if matchReportObj:
                logging.info("Report complete, matched")
                waiting = False
                html_ready_to_save = True
            
        except:
            logging.warn("Exception")
            logging.info("Current browser url:%s", session.current_url)
            
    else:
        logging.info("Report url not matched yet")       
         

if html_ready_to_save:
    filename = "{}__{}__{}".format(datetime.now(),website_url,session.current_url)
    filename = urllib.quote_plus(filename)
    full_filepath = "{}/{}.html".format(saved_html_files_location,filename)
    logging.info("Going to save html source code here:%s",full_filepath ) 
    html_file = io.open(full_filepath, "w", encoding="utf8")
    html_file.write(session.page_source)
    html_file.close()
    html_files_to_process[website_url] = "full_filepath"
    
    
session.quit()
logging.info("Quit session connection")

# END SCAN LOOP
# All urls should be scanned by this point
# now start processing html files


# html elements of interest

# BEGIN HTML FILE PROCESSING LOOP



url_key = random.choice(html_files_to_process.keys())
logging.info("Selected key for processing: ", url_key)

scanned_filename = html_files_to_process[url_key]
logging.info("Actual file to process: ", scanned_filename)

the_file = open(scanned_filename, "r")
file_contents = the_file.read()
webpage = BeautifulSoup(file_contents,'html.parser')
logging.info(webpage.prettify())



logging.info("Program complete.")


