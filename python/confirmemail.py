#Import smtplib for the actual sending function
import smtplib
import redis
import json, sys, time

# Import the email modules we'll need
from email.mime.text import MIMEText

s = smtplib.SMTP('paperlessclub.org')

r = redis.Redis()
p = r.pubsub()

p.subscribe("RegReqConfEmail")

def sendmail(json_msg):
    msg = MIMEText("Paperless CLub registration request confirmation message")
    msg['Subject'] = "Paperless CLub registration request confirmation message"
    msg['To'] = json_msg['email']
    msg['From'] = "bot@paperlessclub.org"
    msg['Display Name'] = json_msg['name']
    s.send_message(msg)

def sendconfemail(msg):
    print(str(msg))
    try:
        j_son = msg.decode('utf-8')
        vj_son = json.loads(j_son)
        print(vj_son)
        #sendmail(vj_son)
    except AttributeError:
        print(msg, " :: Possibly the literal is not string and cannot be treated as JSON")
    except ValueError:
        print("Possible illegal JSON structure")
    except:
        print("something wrong", sys.exc_info()[0])


for message in p.listen():
    sendconfemail(message['data'])

# while True:
#     msg = p.get_message()
#     if msg:
#         sendconfemail(msg['data'])
#     time.sleep(0.001)

p.close()

s.quit()

