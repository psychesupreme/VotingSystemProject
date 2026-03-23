using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

// 1. ADD CORS POLICY: This tells .NET to accept requests from the Angular frontend
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAngularDevClient",
        b => b.WithOrigins("http://localhost:4200")
              .AllowAnyHeader()
              .AllowAnyMethod());
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// 2. USE CORS: This must be placed exactly here, BEFORE UseAuthorization
app.UseCors("AllowAngularDevClient"); 

app.UseAuthorization();
app.MapControllers();
app.Run();