# Zephyr project migration

## 1. Export Zephyr project.

The only way to retrieve the steps of each test case is to put all of them in a test cycle and to export that test cycle.
You can do it (bulk) by following these steps :

 1. Create a dedicated test cycle (called "All Tests" for example).

 ![new test cycle](https://downloads.intercomcdn.com/i/o/45686453/9afe54ce6ac75bbb21688f37/Capture+d%E2%80%99e%CC%81cran+2018-01-17+a%CC%80+16.43.07.png)

 2. In the 'Search Test' section, create a search filter ('save as' button at the top of the page) named 'All tests' that only filter the issueType to 'Test':
 project=<projectId> AND issuetype=Test

 ![search tests section](https://downloads.intercomcdn.com/i/o/45686750/3a97f8186b4445cf6266c8b4/Capture+d%E2%80%99e%CC%81cran+2018-01-17+a%CC%80+16.44.21.png)

 ![new search filter](https://downloads.intercomcdn.com/i/o/45687223/04593cbd710b0c9ff2df21fc/Capture+d%E2%80%99e%CC%81cran+2018-01-17+a%CC%80+16.45.43.png)

 3. Press the 'All Tests' gear in the test cycle list, select "add tests", then enter the filter name 'All tests' in the 'search filter' pane. Validate.

 ![test cycle list](https://downloads.intercomcdn.com/i/o/45687596/b80b2fdef6c1ea7f1daf9a37/Capture+d%E2%80%99e%CC%81cran+2018-01-17+a%CC%80+16.48.30.png)

 ![add tests bulk](https://downloads.intercomcdn.com/i/o/45687792/ead8a9b0f53d1f0ac8e2c02d/Capture+d%E2%80%99e%CC%81cran+2018-01-17+a%CC%80+16.50.38.png)

 4. All your tests are now imported to the 'All Tests' test cycle. You should now be able to export the 'All Tests' test cycle from the 'Search test execution' page.

 ![search test executions](https://downloads.intercomcdn.com/i/o/45688034/083e87926f58f3c3c670d85f/Capture+d%E2%80%99e%CC%81cran+2018-01-17+a%CC%80+16.52.39.png)

 ![select test cycle](https://downloads.intercomcdn.com/i/o/45688531/8c293bbc5817d5532640b55a/Capture+d%E2%80%99e%CC%81cran+2018-01-17+a%CC%80+16.54.15.png)

 ![export test cycle](https://downloads.intercomcdn.com/i/o/45688639/a592178553a2912af84658f9/Capture+d%E2%80%99e%CC%81cran+2018-01-17+a%CC%80+16.55.36.png)

Finally, to have all test informations (like description, etc), could you please try to export all zephyr tests from the 'Search Test' page:

![export search tests](https://downloads.intercomcdn.com/i/o/45689099/1d9fa06201754199006ffb3b/Capture+d%E2%80%99e%CC%81cran+2018-01-17+a%CC%80+15.04.03.png)


## 2. Execute script
### 2.1 => Prepare authentication

Migration script needs some variable to push exported project to Hiptest:

 1. HT_ACCESS_TOKEN, HT_CLIENT, HT_UID: can be found in your Hiptest profile page. Once you have them, export them in your shell session

 2. Now you will have to create a project from Hiptest application then retrieve your project id in the URL : "https://hiptest.net/app/projects/YOUR_PROJECT_ID/" and export it in the HT_PROJECT variable in your shell session.
 
We suggest you to put them in a shell script (here named config.sh) like this
```shell
# config.sh
export HT_ACCESS_TOKEN=<YOUR_ACCESS_TOKEN>
export HT_CLIENT=<YOUR_CLIENT_ID>
export HT_UID=<YOUR_PROFILE_UID>

export HT_PROJECT=<YOUR_PROJECT_ID>
```
And export them all every time you need with `source config.sh`

### 2.2 => Import data

Once every session variables are set, you could launch the script with:
```shell
ruby migrate.rb --info=<INFOS_FILE_PATH> --execution=<EXECUTIONS_FILE_PATH> --only import
```
It will migrate all your scenarios in Hiptest.

### 2.3 => Push results

Now your project is entirely and successfully imported in Hiptest, you can push your execution cycle results with the command:
```shell
ruby migrate.rb --execution=<EXECUTIONS_FILE_PATH> --only push_results
```
PS : *You need to push results for every execution cycle exports you have*

## Notes
The `--only` option is optional, if it is not specified, the script will import then push results.

For more informations, please launch `ruby migrate.rb --help`
