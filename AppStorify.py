import os
import glob
import subprocess
import xml
import xml.etree.ElementTree as ET
import plistlib
import requests
import queue
from concurrent.futures import ThreadPoolExecutor, wait

ITUNES_SEARCH_API = 'https://itunes.apple.com/search'

applications = glob.glob('/Applications/*.app')

infos = dict()
for application in applications:
    a = subprocess.run(['mdls', '-plist', '-', application], stdout=subprocess.PIPE)
    result = plistlib.loads(a.stdout)
    infos[application] = result

# filter apps that are already App Store apps
infos = {app: info for app, info in infos.items() if not info.get('kMDItemAppStoreHasReceipt', False)}

# filter apps that are Apple's apps (in order to filter system apps)
infos = {app: info for app, info in infos.items() if not 'com.apple.' in info.get('kMDItemCFBundleIdentifier', '')}


def get_info(app_name):
    params = {'term': app_name, 'country': 'US', 'media': 'software', 'entity': 'macSoftware', 'limit': 1}
    r = requests.get(url=ITUNES_SEARCH_API, params=params)
    search_info = r.json()
    return search_info


pool = ThreadPoolExecutor(max_workers=10)
app_names = [info['_kMDItemDisplayNameWithExtensions'][:-4] for info in infos.values()]
result = list(pool.map(get_info, app_names))
app_store_search_infos = {key: result[idx] for idx, key in enumerate(infos.keys())}

corresponding_apps = dict()
for app, search_result in app_store_search_infos.items():
    app_name = infos[app]['_kMDItemDisplayNameWithExtensions'][:-4]
    if search_result['resultCount'] == 1:
        if search_result['results'][0]['trackName'] == app_name:
            corresponding_apps[app] = search_result['results'][0]

for key, info in corresponding_apps.items():
    print(key, '\t', info['trackViewUrl'])

