/*
     File: PhotoAnnotation.h
 Abstract: A simple model class to display pins representing photos on the map.
  Version: 1.1 */

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface PhotoAnnotation : NSObject <MKAnnotation>

- (id)initWithImagePath:(NSString *)imagePath title:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) PhotoAnnotation *clusterAnnotation;
@property (nonatomic, strong) NSArray *containedAnnotations;

- (void)updateSubtitleIfNeeded;

@end
