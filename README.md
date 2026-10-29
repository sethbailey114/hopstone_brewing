# Hopstone Brewing: Ordering App

A Flutter ordering app for a fictional brewery, built for CPSC 5330 (UI Fundamentals).

## Features
- Menu of 4 beers with style, ABV, and price
- Quantity selection with live subtotal and total
- Tip toggle that reveals a tip percentage slider
- Age confirmation checkbox required before ordering
- Confirmation dialog on order submission
- Reusable widgets: BeerTile, TipCard, OrderSummary, SummaryRow

## New UI element explored
`Slider` (with divisions and a value label), used for the tip percentage in `TipCard`
in `lib/brewery_app.dart`. `Spacer` and `Divider` are also used.

## Running it
    flutter pub get
    flutter run