<?php

namespace App\Http\Controllers;

use App\Models\CarBuyer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CarBuyerController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $buyers = CarBuyer::latest()->get();
        return response()->json($buyers);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'first_name' => 'nullable|string|max:255',
            'last_name' => 'nullable|string|max:255',
            'email' => 'nullable|email|unique:car_buyers,email',
            'phone' => 'nullable|string|max:255',
            'desired_car_model' => 'nullable|string|max:255',
            'budget' => 'nullable|numeric|min:0',
            'additional_notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $buyer = CarBuyer::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Registration successful!',
            'data' => $buyer
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $buyer = CarBuyer::findOrFail($id);
        return response()->json($buyer);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $buyer = CarBuyer::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'first_name' => 'nullable|string|max:255',
            'last_name' => 'nullable|string|max:255',
            'email' => 'nullable|email|unique:car_buyers,email,' . $id,
            'phone' => 'nullable|string|max:255',
            'desired_car_model' => 'nullable|string|max:255',
            'budget' => 'nullable|numeric|min:0',
            'additional_notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $buyer->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Updated successfully!',
            'data' => $buyer
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $buyer = CarBuyer::findOrFail($id);
        $buyer->delete();

        return response()->json([
            'success' => true,
            'message' => 'Deleted successfully!'
        ]);
    }
}
