//
//  Sale.h
//  ASiST
//
//  Created by Oliver Drobnik on 24.12.08.
//  Copyright 2008 drobnik.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Database.h"

@class Country, App, Report;

typedef enum { TransactionTypeSale = 1, TransactionTypeFreeUpdate = 7 } TransactionType;


@interface Sale : NSObject {
	App *app;
	Country *country;
	Report *report;
	NSInteger unitsSold;
	double royaltyPrice;
	NSString *royaltyCurrency;
	double customerPrice;
	NSString *customerCurrency;
	TransactionType transactionType;
	
	// Opaque reference to the underlying database.
    sqlite3 *database;

}

@property(nonatomic, retain) Country *country;
@property(nonatomic, retain) App *app;
@property(nonatomic, assign) Report *report;  // report owns sales, not other way around
@property(nonatomic, assign) double royaltyPrice;
@property(nonatomic, retain) NSString *royaltyCurrency;
@property(nonatomic, assign) double customerPrice;
@property(nonatomic, retain) NSString *customerCurrency;
@property(nonatomic, assign) NSInteger unitsSold;
@property(nonatomic, assign) TransactionType transactionType;

- (id) initWithCountry:(Country *)acountry report:(Report *)areport app:(App *)aapp units:(NSInteger)aunits royaltyPrice:(double)aprice royaltyCurrency:(NSString *)acurrency customerPrice:(double)c_price customerCurrency:(NSString *)c_currency transactionType:(TransactionType)ttype;

- (void)insertIntoDatabase:(sqlite3 *)db;  // needs to be extra so that report hydrate does not insert


@end