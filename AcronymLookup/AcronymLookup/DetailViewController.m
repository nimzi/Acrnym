//
//  DetailViewController.m
//  AcronymLookup
//
//  Created by Paul Agron on 4/10/15.
//  Copyright (c) 2015 Paul Agron. All rights reserved.
//

#import "DetailViewController.h"
#import "LongForm.h"

@interface DetailCell : UITableViewCell
@end

@implementation DetailCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
    //self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    UIFont* font = [UIFont fontWithName:@"Optima" size:self.textLabel.font.pointSize];
    UIFont* detailFont = [UIFont fontWithName:@"Helvetica Neue" size:self.detailTextLabel.font.pointSize];
    UIFont* boldFont = [UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:font.pointSize];
    UIFont* italicFont = [UIFont fontWithDescriptor:[[detailFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:detailFont.pointSize];

    
    self.textLabel.font = boldFont;
    self.detailTextLabel.font = italicFont;
    
    
    //
  
    self.accessoryView = [[UILabel alloc] initWithFrame:CGRectZero];
    UILabel* accessoryView = ((UILabel*)self.accessoryView);
    accessoryView.textColor = [UIColor whiteColor];
    accessoryView.textAlignment = NSTextAlignmentCenter;
    accessoryView.backgroundColor = [UIColor redColor];
    accessoryView.font =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    accessoryView.layer.cornerRadius = 12;
    accessoryView.layer.borderColor = [UIColor orangeColor].CGColor;
    accessoryView.layer.borderWidth = 2;
    [accessoryView.layer setMasksToBounds:YES];
  }
  
  return self;
}

-(void)prepareForReuse {
}

@end



@implementation DetailViewController

-(instancetype)initWithLongForms:(NSArray*)longForms {
  if (self = [super init]) {
    self.longForms = longForms;
    [self.tableView registerClass:[DetailCell class] forCellReuseIdentifier:@"Cell"];
  }
  
  return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - 


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _longForms.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                          forIndexPath:indexPath];
  LongForm* object = _longForms[indexPath.row];
  cell.textLabel.text = object.longForm;
  cell.detailTextLabel.text =
    //[NSString stringWithFormat:@"frequency: %@  since: %@", object.frequency, object.since];
    [NSString stringWithFormat:@"since: %@", object.since];
  
  ((UILabel*)cell.accessoryView).text = [object.frequency description];
  [cell.accessoryView sizeToFit];
  
  CGRect frame = cell.accessoryView.frame;
  cell.accessoryView.frame = CGRectInset(frame, -10, -5);
  
  return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}


@end
