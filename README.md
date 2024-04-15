# Mess Management System

**Features Implemented**

* Authentication Features like ```LogIn``` ```SignUp``` ```ForgotPassword``` and ```LogOut``` using FireBase.
* A Reset Password Email will be sent to reset the password
* Creation of 2 Profiles
  * Admin
  * User
* Creation of 3 FireStore Collections
  * ```users``` Only Users Can ```write``` data and Admins can ```read``` only.
  * ```mess```  Only Admins Can ```write``` data and Users can ```read``` only.
  * ```messRequests``` Both Admins as well as Users can ```read``` and ```write``` the data.
* 2 DashBoards
  * Admin DashBoard where User dosent have any access.
  * User DashBoard where Admin dosent have any access.
* Display User data such as ```Name``` ```Email``` ```Roll Number``` ```Mess Balance``` and ```Current Mess Name``` .

**User Features**

* Mess Change Process
  * User will initiate a mess change request for a perticular mess of his coice
  * The Admin of that will recive the request he can either Accept it or Reject it
  * Till the request is pending or Vacancy of the mess user is applying is 0 or if User is making a request to the same mess he is currently he wont be allowed to do it
  * The changes of the Admin will be reflected on User Dashboard
* Mess Balance Top-Up
  * User can Top-Up thier mess balance by entering a captcha and amount greater than 100 rs.
* A User can see these properties of each and every mess available to them
  * Mess Menu
  * Mess Vacancy
  * Number of Alloted Students in that mess
  * Breakfast, Lunch, Snacks and Dinner Prices of that mess
* A User can Edit thier Information at any point of time.
* Mess Payments
  * Users will have to buy Breakfast, Lunch, Snacks and Dinner tokens available to them for the price of that mess
  * they will have to show those tokens to get mess food.
  * If the Mess Balance is insuffcient then it will give out warning.
  * This will depreceate the use of Mess cards and if Users dosen't want to eat then no money will be deducted.
* The tokens will be saved in ```Transection History``` Tab.

  **Admin Features**

* Creation and Deletion of a Mess
  * Admin can Create or Delete a Mess.
  * No two Mess Names can be samw.
* Adding Mess Menu
* Accepting the Mess Change Pending Requests of students.
* Update the Mess Data
  * Admin can update the Mess Information like
    * Name of Mess.
    * Maximum Capacity [Cannot be lesser than the alloted students in that Mess].
    * Breakfast, Lunch, Snacks and Dinner Prices.
* Admin Can Manuallty De-Allocate a Student from that perticular Mess [User Dashboard will be simulteneously Updated].



**Note :- Admin accounts cannot be registered via a single person it will be done via organization and given to the admin with a sample password which can be changed in future.**

**References used**

* Many Youtube Channels.
* Chat-GPT, BlackBox and Bard for Intensive Logics.
* FireBase Documentations.
* Resources Provided.


**Operating System Used**

* To Code the entire Application - ```Windows```
* Application Supported on ```Android``` [Tried and Tested]
* Min SDK Version - 21 which is ```Android 5```
* Target SDK Version - 33 which is  ```Android 13```


**Screen Shots - [VISIT](https://drive.google.com/drive/folders/1TOzIbLWU3hR18XpSZ_nQ41wrQu_wCsp7?usp=sharing)**


**Video - [VISIT](https://drive.google.com/drive/folders/1dm4N-P6A2HO0ZERKZdPA4hc4DbPBH1hX?usp=sharing)**


**To Download the APK file - [VISIT](https://drive.google.com/drive/folders/1QFBq_ofDHH7QJIsnp7RYRoG9LZL2zQTW?usp=sharing)**
