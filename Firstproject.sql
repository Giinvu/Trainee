    SELECT *
    FROM CovidDeaths
    ORDER BY 3, 4 

    SELECT *
    FROM CovidVaccinations
    ORDER BY 3, 4

    SELECT Location, Date, total_cases, new_cases, total_deaths, population
    FROM CovidDeaths
    ORDER BY 1, 2

    SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
    FROM CovidDeaths
    ORDER BY 1, 2

    SELECT Location, Date, total_cases, population, (total_cases/population)*100 as DeathPercent
    FROM CovidDeaths
    WHERE Location LIKE '%state%'
    ORDER BY Deathpercent 

    SELECT Location, Population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PercentInfection
    FROM CovidDeaths
    GROUP BY Location, Population
    ORDER BY PercentInfection DESC

    SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
    FROM CovidDeaths
    WHERE Continent is not NULL
    GROUP BY Location
    ORDER BY TotalDeathsCount DESC

    SELECT Continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
    FROM CovidDeaths
    WHERE Continent is not NULL
    GROUP BY Continent
    ORDER BY TotalDeathsCount DESC

    SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
    FROM CovidDeaths
    WHERE Continent is NULL
    GROUP BY Location
    ORDER BY TotalDeathsCount DESC

    SELECT date, SUM(cast(new_cases as int)), SUM(cast(new_deaths as int)) as Deathpercent
    FROM CovidDeaths
    WHERE Continent is not NULL
    GROUP BY date
    ORDER BY 1, 2

    SELECT SUM(new_cases) as Totalcases, SUM(new_deaths) as Totaldeaths, SUM(new_deaths)/SUM(new_cases)*100 as Deathpercent
    FROM CovidDeaths
    WHERE Continent is not NULL
    ORDER BY 1, 2

    SELECT *
    FROM CovidDeaths dea
    JOIN CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date

    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY Dea.Location Order BY Dea.Location, Dea.date) as Sumvaccination
    FROM CovidDeaths dea
    JOIN CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    WHERE Dea.continent is not NULL and Dea.Location = 'Czechia'
    ORDER BY 2, 3

    With PopvsVac (Continent, Location, Date, Population, NewVaccination, RollingVaccination)
    as
    (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY Dea.Location Order BY Dea.Location, Dea.date) as RollingVaccination
    FROM CovidDeaths dea
    JOIN CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    WHERE Dea.continent is not NULL and Dea.Location = 'Czechia'
    )
    SELECT *, (RollingVaccination/Population)*100 as RateVac
    FROM PopvsVac
    WHERE NewVaccination is not null

    DROP Table if exists #PercentPopVaccinated

    CREATE Table #PercentPopVaccinated
    (
        Continent NVARCHAR(255),
        Location nvarchar(255),
        Date datetime,
        Population numeric,
        New_vaccinations numeric,
        RollingVaccination NUMERIC
    )

    INSERT INTO #PercentPopVaccinated
     SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY Dea.Location Order BY Dea.Location, Dea.date) as RollingVaccination
    FROM CovidDeaths dea
    JOIN CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    WHERE Dea.continent is not NULL

    SELECT *, (RollingVaccination/Population)*100 as RateVac
    FROM #PercentPopVaccinated


CREATE VIEW PercentPopVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY Dea.Location Order BY Dea.Location, Dea.date) as RollingVaccination
FROM CovidDeaths dea
    JOIN CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    WHERE Dea.continent is not NULL

SELECT *
FROM PercentPopVaccinated
WHERE new_vaccinations is not Null