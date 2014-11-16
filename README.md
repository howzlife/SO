# Orderboard #

This README would normally document whatever steps are necessary to get your application up and running.

### Technology Stack ###

+ Ruby On Rails
    * 2.1.4
    * Haml
    * Sass
* Mongo DB

# Getting Started #
1

```
#!ruby

$ figaro install
```


Set this in the new config/application.yml file which will be generated when you run the above command


```
#!ruby

development:
  EMAIL_USERNAME: "username"
  EMAIL_PASSWORD: "password"
```


You'll need to put spaces in front of the EMAIL... variables (tabs throw an error). It will also add config/application.yml to your .gitignore file so it can't be added to your commits. If you want to know more about figaro [CLICK HERE](https://github.com/laserlemon/figaro)



## Weird things ##

### Company Vendors and PurchaseOrder Vendors ###
It was requested that if vendors change their name in the future, purchase order data will still retain their old name. Doing this required us to keep two versions of the same data, which isn't best practice and causes us is dangerous for data integrity. To make this feature on the back end as succinctly as possible and allow us to revert to a more conventional and integrous data structure later on, I created a polymorphic model called "Vendors" that is shared by the Company and the Purchase Order model. It is an embedded document in each; not a referenced document. 

If the Vendor's name is changed in the future, it's changed in the Company's embedded vendor document only because the vendor controller's methods only reference the Company's vendor doc.

How do we create vendors in the Purchase Order? In the purchase order creation form, instead of using the conventional "fields_for :association" form helper, which would reference the PurchaseOrder.Vendor, we use a select field that has for its data a reference to @company.vendors. The user selects their vendor from the Company.vendor document. And the selected model's hash is then serialized and passed through the form where we save it to the PurchaseOrder.Vendor's document.





[Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)