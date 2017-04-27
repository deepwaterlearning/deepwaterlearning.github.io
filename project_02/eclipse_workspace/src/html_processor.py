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
import os
import sys
import random
import csv
import sqlite3
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from bs4 import BeautifulSoup


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
urls_to_scan = {"http://beststore.addglobal24support.com": "http://beststore.addglobal24support.com" }
html_files_to_process = {"http://beststore.addglobal24support.com": "/Users/intothelight/nycdatascience/tmp/data_dump/scraper_html_files/2017-04-26+17%3A49%3A51.598328__http%3A%2F%2Fbeststore.addglobal24support.com__http%3A%2F%2Furlquery.net%2Freport.php%3Fid%3D1493241203695.html" }


def check_url(url):
    response_code = requests.head(url)
    logging.info("url:%s , status code:%s", url ,response_code.status_code)
    return response_code.status_code < 400

scanner_url = "http://urlquery.net/api/v2/post.php?url=https://www.va.gov"
scanner_primer_url = "http://urlquery.net/index.php"
scanner_report_url = "http://urlquery.net/report.php?id="
website_url = "https://www.va.gov"

    
# session = requests.session()
# session = webdriver.PhantomJS(executable_path="/Users/intothelight/anaconda/pkgs/phantomjs-2.1.1-0/bin/phantomjs")
# session.set_window_size(1439, 799)

# Here we would start our loop to process urls to be scanned
# BEGIN SCAN LOOP
website_url = random.choice(urls_to_scan.keys())
logging.info("Selected url to scan: %s", website_url)


# if check_url(scanner_primer_url):
#     logging.info("Scanner is up")
# else:
#     logging.error("Scanner not available")
#     session.quit()
#     sys.exit()
#      
#      
# if check_url(website_url):
#     logging.info("Target site is up")
# else:
#     logging.warn("Target site not available")
#     session.quit()
#     sys.exit()
#  
#  
# session.get(scanner_primer_url)
# url_box_id = "url"
# url_btn_id = "url-submit"
# url_text_box = session.find_element_by_id(url_box_id)
# url_text_box.send_keys(website_url)
# url_submit_btn = session.find_element_by_id(url_btn_id)
# url_submit_btn.click()
# html_ready_to_save = False
# waiting = True
# wait_time = 30
# report_status_id = "status"
# while waiting:
#  
#     time.sleep(wait_time)
#     logging.info("Current browser url:%s", session.current_url)
#     matchObj = re.search(r"report",session.current_url, re.M|re.I)
#     if matchObj:
#         logging.info("Report url was matched")
#         try:
#             cell = session.find_element_by_id(report_status_id)
#             logging.info("Status element found in html")
#             matchReportObj = re.search(r"Report complete",cell.text, re.M|re.I)
#             if matchReportObj:
#                 logging.info("Report complete, matched")
#                 waiting = False
#                 html_ready_to_save = True
#              
#         except:
#             logging.warn("Exception")
#             logging.info("Current browser url:%s", session.current_url)
#              
#     else:
#         logging.info("Report url not matched yet")       
#           
#  
# if html_ready_to_save:
#     filename = "{}__{}__{}".format(datetime.now(),website_url,session.current_url)
#     filename = urllib.quote_plus(filename)
#     full_filepath = "{}/{}.html".format(saved_html_files_location,filename)
#     logging.info("Going to save html source code here:%s",full_filepath ) 
#     html_file = io.open(full_filepath, "w", encoding="utf8")
#     html_file.write(session.page_source)
#     html_file.close()
#     html_files_to_process[website_url] = "full_filepath"
#      
#      
# session.quit()
# logging.info("Quit session connection")

# END SCAN LOOP
# All urls should be scanned by this point
# now start processing html files


# html elements of interest

# BEGIN HTML FILE PROCESSING LOOP



url_key = random.choice(html_files_to_process.keys())
logging.info("Selected key for processing: %s", url_key)

scanned_filename = html_files_to_process[url_key]
logging.info("Actual file to process: %s", scanned_filename)

the_file = open(scanned_filename, "r")
file_contents = the_file.read()
webpage = BeautifulSoup(file_contents,'html.parser')
#logging.info(webpage.prettify())

# data of interest
ip_address = ""
asn = ""
location = ""
report_date = ""
urlquery_alerts = 0
user_agent = ""
snort = 0
suricata = 0
fortinet = 0
mdl = 0
dns_bh = 0
ms_dns = 0
openfish = 0
phishtank = 0
spamhaus = 0
jses = 0
jsee = 0
jsew = 0
http_tranx = 0

no_alerts = "No alerts detected"

# we'll cycle through all the page sections
all_h2_elements = webpage.findAll('h2')
for tag in all_h2_elements:
    section_text = tag.get_text()
    if section_text == "Overview":
        logging.info("Overview h2 element found")
        table_element = tag.findNextSibling('table')
        all_cells = table_element.tbody.findAll("td")
        logging.info("total number of <td> cells:%s", len(all_cells))
        i = 0
        logging.info("URL=%s", all_cells[1].contents[0].strip())
        logging.info("IP=%s", all_cells[4].contents[0].strip())
        logging.info("ASN=%s", all_cells[6].contents[0].strip())
        logging.info("Location=%s", all_cells[8].contents[0]['title'])
        logging.info("Report Completed Date=%s", all_cells[10].contents[0].strip())
        logging.info("Report Status=%s", all_cells[12].contents[0].contents[0])
        logging.info("urlQuery Alerts=%s", all_cells[14].contents[0].strip())
        for cell in all_cells:
            logging.info("cell content:%s, index=%s",cell.contents[0], i)
            i = i + 1
    elif section_text == "Settings":
        logging.info("Settings h2 element found")  
        table_element = tag.findNextSibling('table')
        all_cells = table_element.tbody.findAll("td")
        logging.info("total number of <td> cells:%s", len(all_cells))
        i = 0
        for cell in all_cells:
            if not cell.contents:
                value = "NA"
            else:
                value = cell.contents[0]    
            logging.info("cell content:%s, index=%s",value, i)
            i = i + 1
        logging.info("User Agent=%s", all_cells[1].contents[0].strip())    
    elif section_text == "Intrusion Detection Systems":
        logging.info("Intrusion Detection Systems h2 element found")  
        table_element = tag.findNextSibling('table')
        all_cells = table_element.tbody.findAll("td")
        logging.info("total number of <td> cells:%s", len(all_cells))
        i = 0
        for cell in all_cells:
            if not cell.contents:
                value = "NA"
            else:
                value = cell.contents[0]    
            logging.info("cell content:%s, index=%s",value, i)
            i = i + 1
        logging.info("Snort=%s", all_cells[1].contents[0].strip())
        logging.info("Suricata=%s", all_cells[3].contents[0].strip())   
                 
    elif section_text == "Blacklists":
        logging.info("Blacklists h2 element found")
        table_element = tag.findNextSibling('table')
        all_cells = table_element.tbody.findAll("td")
        logging.info("total number of <td> cells:%s", len(all_cells))
        if len(all_cells) > 14:
            row = table_element.tbody.tr
            has_table = row.find("table")
            if has_table:
                fortinet = 1
            else:
                fortinet = 0
            row = row.findNextSibling("tr")
            has_table = row.find("table")
            if has_table:
                mdl = 1
            else:
                mdl = 0
            row = row.findNextSibling("tr")
            has_table = row.find("table")
            if has_table:
                dns_bh = 1
            else:
                dns_bh = 0
            row = row.findNextSibling("tr")
            has_table = row.find("table")
            if has_table:
                ms_dns = 1
            else:
                ms_dns = 0
            row = row.findNextSibling("tr")
            has_table = row.find("table")
            if has_table:
                openfish = 1
            else:
                openfish = 0
            row = row.findNextSibling("tr")
            has_table = row.find("table")
            if has_table:
                phishtank = 1
            else:
                phishtank = 0 
            row = row.findNextSibling("tr")
            has_table = row.find("table")
            if has_table:
                spamhaus = 1
            else:
                spamhaus = 0                
            # there are some tables in here
        else:          
            i = 0
            for cell in all_cells:
                if not cell.contents:
                    value = "NA"
                else:
                    value = cell.contents[0]    
                logging.info("cell content:%s, index=%s",value, i)
                i = i + 1  
            # 14 td elements means no alerts detected anywhere
                 
            fortinet = 0  # all_cells[1].contents[0].strip()
            mdl = 0       # all_cells[3].contents[0].strip()
            dns_bh = 0    # all_cells[5].contents[0].strip()
            ms_dns = 0    # all_cells[7].contents[0].strip()
            openfish = 0  # all_cells[9].contents[0].strip()
            phishtank = 0 # all_cells[11].contents[0].strip()
            spamhaus = 0  # all_cells[13].contents[0].strip()
            
        logging.info("Fortinet=%s", fortinet)  
        logging.info("MDL=%s", mdl)  
        logging.info("DNS_BH=%s", dns_bh) 
        logging.info("MS_DNS=%s", ms_dns)
        logging.info("OpenPhish=%s", openfish)
        logging.info("PhishTank=%s", phishtank)
        logging.info("Spamhaus=%s", spamhaus)    
        
    elif section_text == "JavaScript":
        logging.info("JavaScript h2 element found")
        next_h3_tags = webpage.findAll("h3", text=re.compile("Executed"))
        logging.info("total number of <h3> cells:%s", len(next_h3_tags))
        i = 0
        for cell in next_h3_tags:
            if not cell.contents:
                value = "NA"
            else:
                value = cell.contents[0]    
            logging.info("cell content:%s, index=%s",value, i)
            i = i + 1
        #logging.info("Spamhaus=%s", all_cells[13].contents[0].strip())
        num_of_tranx = "0"
        searchObj = re.search( r'(\d+)', next_h3_tags[0].contents[0], re.M|re.I)
        if searchObj:
            logging.info("js executed scripts tranx search found:%s", searchObj.group())
            num_of_tranx = searchObj.group()
        logging.info("JS_ES=%s", num_of_tranx)
        num_of_tranx = "0"
        searchObj = re.search( r'(\d+)', next_h3_tags[1].contents[0], re.M|re.I)
        if searchObj:
            logging.info("js executed evals tranx search found:%s", searchObj.group())
            num_of_tranx = searchObj.group()
        logging.info("JS_EE=%s", num_of_tranx)
        num_of_tranx = "0"
        searchObj = re.search( r'(\d+)', next_h3_tags[2].contents[0], re.M|re.I)
        if searchObj:
            logging.info("js executed writes tranx search found:%s", searchObj.group())
            num_of_tranx = searchObj.group()
        logging.info("JS_EW=%s", num_of_tranx)
    elif section_text.startswith("HTTP Transactions"):
        logging.info("HTTP Transactions h2 element found: %s", section_text)
        num_of_tranx = "0"
        searchObj = re.search( r'(\d+)', section_text, re.M|re.I)
        if searchObj:
            logging.info("http tranx search found:%s", searchObj.group())
            num_of_tranx = searchObj.group()
        logging.info("HTTP Tranx=%s", num_of_tranx)    
    else:
        logging.info("Ignoring this h2 element: %s", section_text)            

logging.info("Program complete.")


